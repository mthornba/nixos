# NixOS Configs

## Installing Nix on macOS (Darwin)

### Prerequisites

**1. Xcode Command Line Tools (Required)**

Before installing Nix, you need the Xcode Command Line Tools (required for git, compilers, and build tools):

```sh
xcode-select --install
```

Or allow macOS to prompt you when you first try to use `git`. This installs the lightweight tools (~1GB), not the full Xcode app.

Verify installation:
```sh
xcode-select -p
# Should output: /Library/Developer/CommandLineTools
```

**2. Rosetta 2 (Apple Silicon only)**

If you're on an M-series Mac (M5, M4, M3, etc.) and plan to use Intel Homebrew packages, install Rosetta 2:

```sh
softwareupdate --install-rosetta
```

This allows running x86_64 binaries on ARM. Required for `nix-homebrew.enableRosetta = true` in the configuration.

### Option 1: Determinate Systems Installer (Recommended for M5)

The [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer) provides a modern, opinionated installation with better defaults:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Benefits:**
- Flakes and nix-command enabled by default
- Better uninstall support
- Optimized for modern macOS (including Apple Silicon)
- Maintained by Determinate Systems

### Option 2: Official Multi-User Install

The traditional Nix installation:

```sh
sh <(curl -L https://nixos.org/nix/install)
```

Then enable flakes by adding to `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### After Installation

1. Restart your terminal or source the nix profile:
   ```sh
   source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   ```

2. Verify installation:
   ```sh
   nix --version
   ```

3. Clone this repository and apply configuration (see sections below)

---

## NixOS Installation

- Perform intiial install from USB, creating my user
- reboot

## Upgrade to unstable channel

Is this necessary if I'm going to use flakes?
```sh
sudo -i
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
nixos-rebuild switch --upgrade
```

## Flakes

1. Install `git` in a `nix shell`
```sh
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git
```

2. Clone this repo
```sh
git clone https://github.com/mthornba/nixos.git ~/.nixos
```

3. Load system config with a flake
```sh
sudo nixos-rebuild switch --flake .#
```
optionally, including the hostname:
```sh
sudo nixos-rebuild switch --flake .#neon
```

In some cases, such as the initial install, need to specify the hostname.

## X11 vs Wayland

By default, NixOS uses Wayland:
```sh
❯ echo $XDG_SESSION_TYPE
wayland
```

Add to `configuration.nix` to allow choosing between X11 and Wayland at login:
```nix
services.xserver.displayManager.defaultSession = "gnome-xorg";
```

## Home Manager

Add the master branch since we're following NixOS Unstable
```sh
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --update
```

Install Standalone
```sh
nix-shell '<home-manager>' -A install
```

Move Home Manager config into this repo
```sh
mv ~/.config/home-manager/home.nix users/matt
```

Apply Home Manager Config
```sh
home-manager switch -f ./users/matt/home.nix
```

### Allow Unfree

From [github.com/Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs/blob/972935c1b35d8b92476e26b0e63a044d191d49c3/minimal/home-manager/home.nix#L19):
Add to `home.nix`:
```nix
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
```

### Flakes

Install home-manager as a flake
```sh
nix run home-manager/master -- init
mv ~/.config/home-manager/* ./users/matt
home-manager switch --flake ./users/matt/flake.nix
```

If you don't need the initial config created:
```sh
nix run home-manager/master -- switch --flake ./users/matt
```
This will also install `home-manager` if `home.nix` includes:
```nix
# Let Home Manager install and manage itself.
programs.home-manager.enable = true;
```

#### Upgrading Packages

Update all flake inputs (root includes NixOS and darwin, users/matt is home-manager):
```sh
nix flake update && (cd users/matt && nix flake update)
```

Then rebuild:
```sh
nix run .  # Auto-detects OS and hostname
```

Or update and rebuild home-manager only:
```sh
cd users/matt
nix flake update
home-manager switch --flake .
```

## nix-darwin

The darwin configuration is now managed via the root flake at `systems/darwin/`.

### First Time Setup (Bootstrap)

On a fresh Nix installation, bootstrap in this order:

**Step 1: Bootstrap nix-darwin** (requires sudo for system activation):

```sh
sudo nix run nix-darwin -- switch --flake .#Matts-MacBook-Pro  # Intel
sudo nix run nix-darwin -- switch --flake .#Matts-M5           # M5
```

**Step 2: Restart your shell** to pick up darwin-rebuild in PATH:

```sh
exec $SHELL
```

**Step 3: Bootstrap home-manager**:

```sh
nix run home-manager/release-25.11 -- switch --flake ./users/matt
```

**Step 4: Restart shell again** to pick up home-manager in PATH:

```sh
exec $SHELL
```

After bootstrap, both `darwin-rebuild` and `home-manager` are installed.

### Subsequent Builds

After the initial bootstrap, use the simpler commands:

```sh
nix run .  # Auto-detects hostname and OS
```

Or explicitly:
```sh
darwin-rebuild switch --flake .#Matts-MacBook-Pro  # Intel
darwin-rebuild switch --flake .#Matts-M5           # M5
```

## Support for multiple platforms

Execute a helper script that checks the platform and determines how to apply the configuration.
```sh
nix run .
```

Optionally allow broken packages
```sh
NIXPKGS_ALLOW_BROKEN=1 nix run .
```

## Aerospace

[AeroSpace](https://github.com/nikitabobko/AeroSpace) is an i3-like tiling window manager for macOS.

### Configuration

The Aerospace configuration is managed in `users/matt/home.nix` under `programs.aerospace.settings`.

### Adding Apps to Floating Window List

Some apps work better as floating windows (e.g., Calculator, System Preferences). To add an app to the floating list:

1. **Find the app's bundle ID:**
   ```sh
   osascript -e 'id of app "Application Name"'
   ```
   
   Example:
   ```sh
   osascript -e 'id of app "Calculator"'
   # Output: com.apple.calculator
   ```

2. **Add to `users/matt/home.nix`:**
   
   Find the `on-window-detected` section and add a new entry:
   ```nix
   programs.aerospace.settings = {
     on-window-detected = [
       # ... existing entries ...
       
       # Your new app
       { "if" = { app-id = "com.example.app"; }; run = "layout floating"; }
     ];
   };
   ```

3. **Optional: Match by window title:**
   
   To float only specific windows (e.g., preferences):
   ```nix
   { "if" = { 
       app-id = "com.example.app"; 
       window-title-regex-substring = "Preferences"; 
     }; 
     run = "layout floating"; 
   }
   ```

4. **Apply the changes:**
   ```sh
   cd users/matt
   home-manager switch --flake .
   ```
   
   Aerospace will automatically reload with the new configuration.

### Currently Floating Apps

- System Preferences/Settings
- Calculator
- Activity Monitor
- Archive Utility
- Software Update
- Finder Info/Preferences windows
- UTM

### Key Bindings

- `Alt + Shift + Space`: Toggle between tiling and floating for current window
- `Alt + /`: Toggle between horizontal and vertical tiling layouts
- `Alt + ,`: Toggle accordion layout
- See full keybindings in `users/matt/home.nix` under `mode.main.binding`

