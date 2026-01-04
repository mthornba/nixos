#!/usr/bin/env bash
set -euo pipefail

# Usage: launch_or_focus_by_name.sh <session-name>
NAME="${1:?session name required}"

# 1) Try to raise the OS window without changing internal focus
INFO="$(kitten @ ls)"
TAB_ID="$(
  printf '%s' "$INFO" |
  jq -r --arg name "$NAME" '
    .[]? as $os
    | select(any($os.tabs[]?.windows[]?; .session and
                 (.session == $name or
                  (.session | test("(^|/)" + $name + "\\.kitty-session$")))))
    | $os.tabs[]? | select(.is_active==true) | .id
  ' | head -n1
)"
if [[ -n "${TAB_ID:-}" ]]; then
  exec kitten @ focus-tab --match "id:${TAB_ID}"
fi

# 2) Not running → load the session
# Prefer a new OS window so the current window stays untouched.
# Resolve NAME to a file if possible, else let kitty resolve it.
resolve_session_path() {
  local n="$1"
  local -a candidates=(
    "$HOME/.local/share/kitty/sessions/${n}.kitty-session"
    "$HOME/.config/kitty/${n}.kitty-session"
    "$HOME/Code/nixos/users/matt/dotfiles/kitty/${n}.kitty-session"
  )
  for p in "${candidates[@]}"; do
    [[ -f "$p" ]] && { printf '%s\n' "$p"; return 0; }
  done
  return 1
}

if SESSION_FILE="$(resolve_session_path "$NAME")"; then
  # macOS: start a new app instance window with that session file
  exec open -na "/Applications/kitty.app" --args --single-instance=no --session "$SESSION_FILE"
else
  # fallback: let kitty resolve NAME (works if you saved sessions to kitty’s default dir)
  exec open -na "/Applications/kitty.app" --args --single-instance=no --session "$NAME"
fi

