# Multi-Architecture Darwin Configuration - Summary

## Changes Made

### Structure Restructuring
- Created `systems/darwin/common/` for shared macOS configuration
- Created `systems/darwin/hosts/` for host-specific settings
- Moved from per-host flakes to unified darwin configuration

### Files Created
1. **systems/darwin/common/default.nix** - Shared system configuration
   - System packages (with architecture-aware iproute2mac)
   - Nix settings (caches, trusted users)
   - macOS system defaults (dock, NSGlobalDomain, hotkeys)

2. **systems/darwin/common/brew.nix** - Shared Homebrew configuration
   - Formulae (brews)
   - Casks with architecture-aware filtering (virtualbox only on Intel)
   - Users configuration

3. **systems/darwin/hosts/Matts-MacBook-Pro.nix** - Intel-specific
   - `nixpkgs.hostPlatform = "x86_64-darwin"`
   - `nix-homebrew.enableRosetta = false`

4. **systems/darwin/hosts/Matts-M5.nix** - Apple Silicon-specific
   - `nixpkgs.hostPlatform = "aarch64-darwin"`
   - `nix-homebrew.enableRosetta = true`

5. **systems/darwin/flake-module.nix** - Darwin configuration factory
   - Creates both darwinConfigurations
   - Imports common + host-specific modules
   - Configures nix-homebrew with taps

### Root Flake Changes
- Added darwin-related inputs (nix-darwin, nix-homebrew, homebrew taps)
- Added `aarch64-darwin` to supported systems
- Imported darwin configurations from flake-module
- Updated `nix run .` to auto-detect hostname (not hardcoded path)

### Home Manager Changes
- Added M5 home configurations for both architectures:
  - `matt@Matts-M5` (aarch64-darwin)
  - `matt@Matts-M5.local` (aarch64-darwin)

### Architecture-Aware Logic

**Package Filtering**:
```nix
] ++ lib.optionals (!pkgs.stdenv.isDarwin || pkgs.stdenv.hostPlatform.isx86_64) [
  iproute2mac  # Only on Intel
];
```

**Cask Filtering**:
```nix
casks = [ ... ] ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
  "virtualbox"  # Intel-only
];
```

## Usage

### Current Intel System
```bash
nix run .  # Auto-detects Matts-MacBook-Pro
# Or explicitly:
darwin-rebuild switch --flake .#Matts-MacBook-Pro
```

### Future M5 System
```bash
# Set hostname first:
sudo scutil --set HostName Matts-M5
sudo scutil --set LocalHostName Matts-M5

# Then:
nix run .  # Auto-detects Matts-M5
# Or explicitly:
darwin-rebuild switch --flake .#Matts-M5
```

### Home Manager
Works automatically for both:
```bash
home-manager switch --flake ./users/matt
# Detects matt@Matts-M5 or matt@Matts-MacBook-Pro
```

## Benefits

1. **Zero Code Duplication**: Shared config in `common/`, only architecture differs in `hosts/`
2. **Architecture-Aware**: Packages and casks automatically filtered by platform
3. **Future-Proof**: Easy to add more hosts (just create new file in `hosts/`)
4. **Maintainable**: Single source of truth for macOS configuration
5. **Parallel Use**: Both systems can coexist with different hostnames

## Migration Path

### For Parallel Use (Recommended)
1. Keep current Intel system as-is
2. On M5, set hostname to `Matts-M5`
3. Clone repo and run `nix run .`
4. Both systems work independently

### For Direct Replacement
1. On M5, set hostname to `Matts-MacBook-Pro`
2. Configuration auto-selects correct architecture
3. Everything "just works" with same hostname

## Verification

```bash
# Check configurations exist
nix eval .#darwinConfigurations --apply builtins.attrNames
# Output: [ "Matts-M5" "Matts-MacBook-Pro" ]

# Check architecture
nix eval .#darwinConfigurations.Matts-M5.config.nixpkgs.hostPlatform
# Output: "aarch64-darwin"

nix eval .#darwinConfigurations.Matts-MacBook-Pro.config.nixpkgs.hostPlatform
# Output: "x86_64-darwin"
```

## Legacy Directory

The original `systems/Matts-MacBook-Pro/` directory is kept temporarily for reference but gitignored. It can be removed once migration is confirmed successful.
