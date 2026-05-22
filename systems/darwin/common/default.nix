{ config, pkgs, lib, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    curl
    iproute2mac
    qemu
    unstable.raycast
    vim
    wget
  ];

  # Necessary for using flakes on this system
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.settings.trusted-users = [ "@admin" "matt" ];

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  system.primaryUser = "matt";

  system.defaults = {
    dock = {
      appswitcher-all-displays = true;
      autohide = true;
      expose-group-apps = true; # Group windows by application
      persistent-apps = [
        "/Applications/Vivaldi.app"
      ];
      persistent-others = [
        "/Users/matt/Applications"
      ];
      wvous-bl-corner = 1; # Disabled
      wvous-br-corner = 2; # Mission Control
    };
    
    spaces.spans-displays = false; # Enable "Displays have separate spaces"

    NSGlobalDomain = {
      _HIHideMenuBar = false; # autohide menu bar
      AppleInterfaceStyle = "Dark";
      AppleIconAppearanceTheme = "RegularDark"; # menu bar icon style
      # Disable press and hold for diacritics (to allow holding down vim keys in vscode)
      ApplePressAndHoldEnabled = false;
      AppleShowAllFiles = true; # show hidden files
      KeyRepeat = 2; # how fast keys repeat
      NSAutomaticCapitalizationEnabled = false;
      NSWindowShouldDragOnGesture = true; # drag windows from anywhere
    };
    
    # Disable keyboard shortcuts that conflict with terminal applications
    # Symbolic hotkey 60 = "Select the previous input source"
    # Symbolic hotkey 61 = "Select next source in Input menu"
    # Symbolic hotkey 64 = "Show Spotlight search"
    # Symbolic hotkey 65 = "Show Finder search window"
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "60" = {
            enabled = false;
            value = {
              parameters = [ 32 49 1048576 ];
              type = "standard";
            };
          };
          "61" = {
            enabled = false;
            value = {
              parameters = [ 32 49 1572864 ];
              type = "standard";
            };
          };
          "64" = {
            enabled = false;
            value = {
              parameters = [ 65535 49 1048576 ];
              type = "standard";
            };
          };
          "65" = {
            enabled = false;
            value = {
              parameters = [ 65535 49 1572864 ];
              type = "standard";
            };
          };
        };
      };
    };
    
    LaunchServices.LSQuarantine = false;
  };

  # Set Git commit hash for darwin-version
  system.configurationRevision = null;

  # Used for backwards compatibility
  system.stateVersion = 4;
}
