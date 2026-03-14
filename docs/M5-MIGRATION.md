# M5 MacBook Migration Guide

## Overview
Migration from Intel MacBook Pro (x86_64-darwin) to M5 MacBook (aarch64-darwin/arm64).

## Architecture Changes Required

### 1. System Flake Platform
**File**: `systems/Matts-MacBook-Pro/flake.nix` (line 146)

**Current**:
```nix
nixpkgs.hostPlatform = "x86_64-darwin";
```

**For M5**:
```nix
nixpkgs.hostPlatform = "aarch64-darwin";
```

### 2. Rosetta 2 Configuration
**File**: `systems/Matts-MacBook-Pro/flake.nix` (line 162)

**Current**:
```nix
enableRosetta = false;
```

**For M5** (to support x86_64 apps if needed):
```nix
enableRosetta = true;
```

### 3. Home Manager System Architecture
**File**: `users/matt/flake.nix`

**Current**:
```nix
"matt@Matts-MacBook-Pro" = mkHome "x86_64-darwin";
"matt@Matts-MacBook-Pro.local" = mkHome "x86_64-darwin";
```

**For M5**:
```nix
"matt@Matts-MacBook-Pro" = mkHome "aarch64-darwin";
"matt@Matts-MacBook-Pro.local" = mkHome "aarch64-darwin";
# Or create new host entries for M5 system
"matt@Matts-M5-MacBook-Pro" = mkHome "aarch64-darwin";
```

### 4. Root Flake Supported Systems
**File**: `flake.nix` (line 30)

**Current**:
```nix
supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
```

**Update to**:
```nix
supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
```

## Package Compatibility Review

### ✅ Fully Compatible Packages
Most packages in your configuration are architecture-agnostic:
- All CLI tools (bat, ripgrep, fd, jq, etc.)
- Terminal emulators (kitty)
- Shell tools (zsh, tmux, neovim)
- Development tools (docker-client, terraform, kubectl)
- Nix-managed GUI apps (vscode, slack, firefox)

### ⚠️ Potentially Problematic Packages

**VirtualBox** (Homebrew cask)
- Status: **NOT SUPPORTED on Apple Silicon**
- Alternative: Use UTM (already in your casks) or Parallels Desktop
- Action: Remove `virtualbox` from `systems/Matts-MacBook-Pro/brew/casks.nix`

**iproute2mac** (system package)
- Status: May need recompilation for ARM
- Verification needed after migration
- Location: `systems/Matts-MacBook-Pro/flake.nix:60`

**OrbStack** (Homebrew cask)
- Status: Fully supports Apple Silicon
- No changes needed

### 📦 Package-Specific Notes

**ekphos** (users/matt/home.nix:42-73)
- Custom Rust build from source
- Should compile fine for aarch64-darwin
- Uses Darwin SDK frameworks which are architecture-independent

**pgcli/postgresql workaround** (users/matt/home.nix:27-39)
- Darwin-specific stub already in place
- Works on both architectures
- No changes needed

## Recommended Migration Strategy

### Option A: In-Place Migration (Recommended for Parallel Use)

**Step 1**: Create separate system configurations
```bash
# Copy existing config to new directory
cp -r systems/Matts-MacBook-Pro systems/Matts-M5-MacBook-Pro
```

**Step 2**: Update M5 configuration
```nix
# systems/Matts-M5-MacBook-Pro/flake.nix
nixpkgs.hostPlatform = "aarch64-darwin";
enableRosetta = true;  # Enable for compatibility

# Remove VirtualBox from brew/casks.nix
# (already removed: virtualbox line)
```

**Step 3**: Update home-manager
```nix
# users/matt/flake.nix
"matt@Matts-M5-MacBook-Pro" = mkHome "aarch64-darwin";
```

**Step 4**: Update root flake
```nix
# flake.nix - add new darwin configuration
darwinConfigurations."Matts-M5-MacBook-Pro" = ...
```

### Option B: Direct Replacement

If you want to keep the same hostname:

**Step 1**: Before migration, note your hostname
```bash
hostname
# Matts-MacBook-Pro.local or similar
```

**Step 2**: On new M5, set same hostname
```bash
sudo scutil --set HostName Matts-MacBook-Pro
sudo scutil --set LocalHostName Matts-MacBook-Pro
sudo scutil --set ComputerName "Matt's MacBook Pro"
```

**Step 3**: Update flake.nix architecture
```nix
nixpkgs.hostPlatform = "aarch64-darwin";
```

**Step 4**: Update home-manager architecture
```nix
"matt@Matts-MacBook-Pro" = mkHome "aarch64-darwin";
```

## Post-Migration Verification

### Test Commands
```bash
# Verify architecture
uname -m
# Should show: arm64

# Test nix build
nix run . --dry-run

# Verify all packages
home-manager packages | grep -i error

# Test Rosetta (if enabled)
arch -x86_64 /bin/bash -c "uname -m"
# Should show: x86_64
```

### Known Issues & Solutions

**Issue**: "Not a trusted user" warning
- Solution: Already configured in your flake
- Verify: Restart nix-daemon after migration

**Issue**: Homebrew architecture mismatch
- Solution: Homebrew auto-detects and uses correct path
  - ARM: `/opt/homebrew`
  - Intel: `/usr/local/homebrew`
- Action: nix-homebrew handles this automatically

**Issue**: Docker images for wrong architecture
- Solution: OrbStack handles multi-arch automatically
- Verify: `docker run --rm arm64v8/alpine uname -m`

## Files Requiring Updates

### Minimal Changes (Same Hostname)
1. `systems/Matts-MacBook-Pro/flake.nix` - Change hostPlatform
2. `systems/Matts-MacBook-Pro/brew/casks.nix` - Remove virtualbox
3. `users/matt/flake.nix` - Change architecture for hostname entry
4. `flake.nix` - Add aarch64-darwin to supportedSystems

### Full Parallel Setup (Different Hostname)
1. Create `systems/Matts-M5-MacBook-Pro/` directory
2. Copy and modify all files from existing system
3. Add new darwinConfiguration to root flake
4. Add new home-manager entry in users/matt/flake.nix
5. Update supportedSystems in root flake

## Timeline

### Immediate (Before M5 Arrival)
- [ ] Add aarch64-darwin to supportedSystems
- [ ] Remove VirtualBox from casks
- [ ] Decide on hostname strategy

### During Parallel Use (If Applicable)
- [ ] Create separate M5 configuration
- [ ] Test build on Intel system
- [ ] Copy SSH keys, credentials

### M5 First Boot
- [ ] Clone nixos repo
- [ ] Run `nix run .` to apply configuration
- [ ] Verify all packages installed correctly
- [ ] Test critical workflows

### Post-Migration
- [ ] Archive or remove Intel-specific config
- [ ] Update AGENTS.md with M5-specific notes
- [ ] Test Rosetta compatibility if needed

## Emergency Rollback

If issues arise, revert to default macOS:
```bash
# Uninstall nix
/nix/nix-installer uninstall

# Fresh start
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

## Additional Resources

- [nix-darwin Apple Silicon docs](https://github.com/LnL7/nix-darwin#apple-silicon)
- [Nixpkgs Darwin support](https://nixos.org/manual/nixpkgs/stable/#chap-darwin)
- [Homebrew on Apple Silicon](https://docs.brew.sh/Installation#macos-requirements)
