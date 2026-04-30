# Vault Token Renewal Service Management

## Overview
The vault token renewal service automatically logs into Vault via OIDC and renews tokens for up to 8 hours.

**Service Name:** `org.nix-community.home.vault-token-renewer`
**Plist Location:** `~/Library/LaunchAgents/org.nix-community.home.vault-token-renewer.plist`
**Script Location:** `~/.local/bin/vault-token-renewer`
**Logs:** `~/Library/Logs/vault-token-renewer.log`
**Errors:** `~/Library/Logs/vault-token-renewer.error.log`

## Configuration
- **Check Interval:** 5 minutes (300 seconds)
- **Renewal Threshold:** Renews if TTL < 10 minutes (600 seconds)
- **Max Runtime:** 8 hours (28800 seconds)
- **Vault Address:** https://vault.internal.palitronica.com

### Customizing Configuration

#### Option 1: Environment Variables (via launchd plist)
Edit `~/.config/nixpkgs/home.nix` in the `launchd.agents.vault-token-renewer` section:

```nix
EnvironmentVariables = {
  PATH = "${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
  VAULT_ADDR = "https://your-vault-server.com";  # Change Vault endpoint
  CHECK_INTERVAL = "600";     # Check every 10 minutes instead of 5
  MIN_TTL = "1200";           # Renew if TTL < 20 minutes instead of 10
  MAX_RUNTIME = "14400";      # Run for 4 hours instead of 8
};
```

Then rebuild: `home-manager switch --flake ./users/matt`

#### Option 2: Edit the Script Directly
Edit `~/nixos/users/matt/scripts/vault-token-renewer.sh` and modify these lines:

```bash
CHECK_INTERVAL=300  # 5 minutes in seconds
MIN_TTL=600         # Renew if TTL < 10 minutes
MAX_RUNTIME=28800   # Stop after 8 hours (28800 seconds)
```

Then rebuild: `home-manager switch --flake ./users/matt`

**Note:** The script reads `VAULT_ADDR` from environment first, then falls back to the default in the script.

### Common Configurations

**Short sessions (2 hours):**
```nix
MAX_RUNTIME = "7200";
```

**Longer check interval (15 minutes):**
```nix
CHECK_INTERVAL = "900";
MIN_TTL = "1800";  # Adjust threshold to 30 minutes
```

**All day session (12 hours):**
```nix
MAX_RUNTIME = "43200";
```

After changing configuration, restart the service:
```bash
launchctl stop org.nix-community.home.vault-token-renewer
launchctl start org.nix-community.home.vault-token-renewer
```

## Daily Use Commands

### Start the service
```bash
launchctl start org.nix-community.home.vault-token-renewer
```

### Stop the service
```bash
launchctl stop org.nix-community.home.vault-token-renewer
```

### Check if service is running
```bash
launchctl list | grep vault
```
- If running, you'll see output with PID
- If stopped, PID will be `-` or `0`

### Check service status (detailed)
```bash
launchctl print gui/$(id -u)/org.nix-community.home.vault-token-renewer
```

### View logs (live tail)
```bash
tail -f ~/Library/Logs/vault-token-renewer.log
```

### View error logs
```bash
tail -f ~/Library/Logs/vault-token-renewer.error.log
```

### View recent log entries
```bash
tail -n 50 ~/Library/Logs/vault-token-renewer.log
```

## Cold Start (After Boot)

The service is configured with `RunAtLoad = false`, so it won't auto-start after reboot.

### Option 1: Start manually when needed
```bash
launchctl start org.nix-community.home.vault-token-renewer
```

### Option 2: Enable auto-start on login
Edit `~/.config/nixpkgs/home.nix` and change:
```nix
RunAtLoad = false;
```
to:
```nix
RunAtLoad = true;
```
Then rebuild: `home-manager switch --flake ./users/matt`

After next login, the service will start automatically.

## Service Lifecycle

### Load service (register with launchd)
```bash
# Only needed if service is unloaded or after home-manager changes
launchctl load ~/Library/LaunchAgents/org.nix-community.home.vault-token-renewer.plist
```

### Unload service (unregister from launchd)
```bash
launchctl unload ~/Library/LaunchAgents/org.nix-community.home.vault-token-renewer.plist
```

### Reload after home-manager changes
```bash
launchctl bootout gui/$(id -u)/org.nix-community.home.vault-token-renewer
home-manager switch --flake ./users/matt
# Service will be automatically loaded by home-manager
```

## Manual Script Execution

Run the script directly (not as a service):
```bash
~/.local/bin/vault-token-renewer
```

This is useful for:
- Testing changes
- Running in foreground to see real-time output
- Debugging issues

Press `Ctrl+C` to stop.

## Troubleshooting

### Service won't start
```bash
# Check if already running
launchctl list | grep vault

# Check for errors in logs
cat ~/Library/Logs/vault-token-renewer.error.log

# Try running script manually
~/.local/bin/vault-token-renewer
```

### Service stops unexpectedly
Check logs for errors:
```bash
tail -50 ~/Library/Logs/vault-token-renewer.log
```

Common reasons:
- Max runtime (8 hours) reached - this is expected behavior
- Vault login failed
- Token renewal failed multiple times

### Reset everything
```bash
# Stop and unload service
launchctl stop org.nix-community.home.vault-token-renewer
launchctl unload ~/Library/LaunchAgents/org.nix-community.home.vault-token-renewer.plist

# Clear logs
> ~/Library/Logs/vault-token-renewer.log
> ~/Library/Logs/vault-token-renewer.error.log

# Clear token
rm -f ~/.vault-token

# Reload service
launchctl load ~/Library/LaunchAgents/org.nix-community.home.vault-token-renewer.plist

# Start fresh
launchctl start org.nix-community.home.vault-token-renewer
```

## Quick Reference

| Action | Command |
|--------|---------|
| Start | `launchctl start org.nix-community.home.vault-token-renewer` |
| Stop | `launchctl stop org.nix-community.home.vault-token-renewer` |
| Status | `launchctl list \| grep vault` |
| Logs | `tail -f ~/Library/Logs/vault-token-renewer.log` |
| Run manually | `~/.local/bin/vault-token-renewer` |

## Typical Daily Workflow

**Morning (start of work day):**
```bash
launchctl start org.nix-community.home.vault-token-renewer
```

**End of day or leaving computer:**
```bash
launchctl stop org.nix-community.home.vault-token-renewer
```

**After 8 hours (automatic):**
Service stops itself - just restart when needed:
```bash
launchctl start org.nix-community.home.vault-token-renewer
```
