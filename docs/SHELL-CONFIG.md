# Shell Configuration Notes

## Zsh Completion

### Fuzzy Substring Matching

Configuration in `users/matt/home.nix`:

```nix
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
```

**What each matcher does:**

1. `m:{a-zA-Z}={A-Za-z}` - **Case insensitive matching**
   - `cd Doc<tab>` matches `Documents`
   - `cd doc<tab>` matches `Documents`

2. `r:|[._-]=* r:|=*` - **Match after delimiters** (underscore, dot, dash)
   - `cd proj<tab>` matches `my_project`
   - `cd config<tab>` matches `app.config`
   - `cd bar<tab>` matches `foo-bar`

3. `l:|=* r:|=*` - **Substring matching anywhere**
   - `cd 123<tab>` matches `abc123`
   - `cd test<tab>` matches `my-test-dir`
   - Matches the substring at any position in the filename

**Examples:**
```bash
cd 123<tab>       # Matches: abc123, test123, 123test
cd proj<tab>      # Matches: my_project, project-name, old-projects
cd conf<tab>      # Matches: app.config, config.yml, myconfig
```

## SSH Configuration

SSH config is managed manually at `~/.ssh/config` (not via Nix) to allow frequent updates.

**Key settings for macOS Keychain integration:**
```
Host *
  UseKeychain yes
  AddKeysToAgent yes
```

This caches SSH key passphrases in macOS Keychain - only need to enter once per reboot.

## Kitty Terminal

### Option Key Behavior

Setting: `macos_option_as_alt` in `users/matt/home.nix`

**Options:**
- `"no"` - Option key passes through to system (for Aerospace)
- `"left"` - Left Option acts as Alt/Meta in terminal
- `"right"` - Right Option acts as Alt/Meta in terminal
- `"both"` - Both Options act as Alt/Meta in terminal

**Current setting:** `"right"`
- **Left Option** - Used by Aerospace for window management keybindings
- **Right Option** - Acts as Alt/Meta for terminal apps (Vim, Emacs, etc.)

**Why this matters:**
- When `macos_option_as_alt = "left"`, kitty enables macOS Secure Input to capture the Option key
- Secure Input blocks all other apps (including Aerospace) from seeing keyboard events
- Active SSH sessions can also trigger Secure Input
- Using `"right"` prevents this conflict

### Secure Input Issues

**Symptoms:**
- Aerospace keybindings stop working randomly
- macOS shows "Secure Input" icon in menu bar
- Option key seems "broken" in some apps

**Common causes:**
- Active SSH sessions in kitty
- Password prompts in terminal (sudo, ssh-add, etc.)
- Kitty capturing Option key with `macos_option_as_alt = "left"`

**Quick fix:**
- Close terminal windows with SSH sessions
- Restart kitty
- Use `macos_option_as_alt = "right"` to avoid the conflict

## GitHub Copilot in Neovim

### CopilotChat Context

Configuration in `users/matt/modules/neovim.nix`:

```nix
require("CopilotChat").setup({
  resources = 'buffer', -- Include buffer context by default
  ...
})
```

This makes CopilotChat automatically see the contents of your currently open file.

**Keybindings:**
- `<Space>cc` - Toggle CopilotChat window
- `<Space>cq` - Quick chat with explicit buffer context
- `<Space>ce` - Explain (works on visual selection or buffer)
- `<Space>cr` - Review code
- `<Space>cf` - Fix/debug code
- `<Space>co` - Optimize code

**How to provide context:**
1. **Current buffer** - Opens automatically with `resources = 'buffer'`
2. **Visual selection** - Select code with `v`, then use commands
3. **Explicit context** - Type `@buffer` in the chat
4. **Multiple files** - Type `@workspace` or use telescope integration

**Dependencies:**
- `plenary-nvim` (required)
- `tiktoken_core` (optional, for better token counting)
- `lynx` (optional, for URL content)
- `ripgrep` (optional, for codebase search)

### Accepting Suggestions Safely

**Problem:** Using `Ctrl-y` to accept inline suggestions can remove lines if the model provides incomplete code blocks.

**Solution:**
- Manually edit specific values when suggestions are incomplete
- Ask model to "show complete function with changes"
- Review diffs carefully before accepting
- Use undo (`u`) if something goes wrong

## GHQ Repository Management

### Aliases and Functions

**`gclone`** - Clone repository with ghq and cd into it
```bash
gclone github.com/user/repo
```

Implemented as a shell function (not alias) to avoid spawning subshells.

**`cdr`** - Fuzzy find and cd to any cloned repository
```bash
cdr  # Opens fzf to select from all ghq repos
```

**Why not use `ghq get -l`?**
The `-l` (look) flag spawns a subshell that can cause issues:
- Changes terminal behavior (Option key breaks)
- Not obvious you're in a subprocess
- Must exit the subshell to restore normal behavior

The custom function achieves the same result without the subshell problem.
