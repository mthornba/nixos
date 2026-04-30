#!/usr/bin/env bash

# Configuration - can be overridden via environment variables
VAULT_ADDR="${VAULT_ADDR:-https://vault.internal.palitronica.com}"
CHECK_INTERVAL="${CHECK_INTERVAL:-300}"  # 5 minutes in seconds
MIN_TTL="${MIN_TTL:-600}"                # Renew if TTL < 10 minutes
MAX_RUNTIME="${MAX_RUNTIME:-28800}"      # Stop after 8 hours (28800 seconds)
TOKEN_FILE="${HOME}/.vault-token"

# Track start time
START_TIME=$(date +%s)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Check if we've exceeded max runtime
check_max_runtime() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    if [ $elapsed -ge $MAX_RUNTIME ]; then
        log "Maximum runtime of $MAX_RUNTIME seconds reached. Stopping."
        return 1
    fi
    return 0
}

# Get current token TTL
get_token_ttl() {
    if [ ! -f "$TOKEN_FILE" ]; then
        return 1
    fi
    
    vault token lookup -format=json 2>/dev/null | jq -r '.data.ttl' 2>/dev/null
}

# Login and get new token
login() {
    log "Logging in to Vault via OIDC..."
    if vault login -method=oidc -token-only > "$TOKEN_FILE" 2>/dev/null; then
        chmod 600 "$TOKEN_FILE"
        export VAULT_TOKEN=$(cat "$TOKEN_FILE")
        log "Successfully logged in"
        return 0
    else
        log "Login failed"
        return 1
    fi
}

# Renew token
renew_token() {
    log "Renewing token..."
    if vault token renew > /dev/null 2>&1; then
        log "Token renewed successfully"
        return 0
    else
        log "Token renewal failed"
        return 1
    fi
}

# Main loop
main() {
    log "Starting Vault token auto-renewal"
    log "Check interval: ${CHECK_INTERVAL}s, Min TTL: ${MIN_TTL}s, Max runtime: ${MAX_RUNTIME}s"
    
    # Initial login
    if ! login; then
        log "Initial login failed. Exiting."
        exit 1
    fi
    
    while true; do
        # Check if max runtime exceeded
        if ! check_max_runtime; then
            exit 0
        fi
        
        # Get current TTL
        ttl=$(get_token_ttl)
        
        if [ -z "$ttl" ] || [ "$ttl" = "null" ]; then
            log "Could not get token TTL. Attempting re-login..."
            if ! login; then
                log "Re-login failed. Exiting."
                exit 1
            fi
        elif [ "$ttl" -lt "$MIN_TTL" ]; then
            log "Token TTL ($ttl seconds) below threshold. Renewing..."
            if ! renew_token; then
                log "Renewal failed. Attempting re-login..."
                if ! login; then
                    log "Re-login failed. Exiting."
                    exit 1
                fi
            fi
        else
            log "Token TTL: ${ttl}s - OK"
        fi
        
        sleep $CHECK_INTERVAL
    done
}

main
