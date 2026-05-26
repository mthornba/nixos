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

  # Aerospace window manager from unstable
  services.aerospace = {
    enable = true;
    package = pkgs.unstable.aerospace;
    settings = {
      start-at-login = false;
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      
      # Windows that should always float
      on-window-detected = [
        { "if" = { app-id = "com.apple.systempreferences"; }; run = "layout floating"; }
        { "if" = { app-id = "com.apple.calculator"; }; run = "layout floating"; }
        { "if" = { app-id = "com.apple.ActivityMonitor"; }; run = "layout floating"; }
        { "if" = { app-id = "com.apple.archiveutility"; }; run = "layout floating"; }
        { "if" = { app-id = "com.microsoft.AzureVpnMac"; }; run = "layout floating"; }
        { "if" = { app-id = "com.apple.SoftwareUpdate"; }; run = "layout floating"; }
        { "if" = { app-id = "com.apple.finder"; }; run = "layout floating"; }
        { "if" = { app-id = "com.utmapp.UTM"; }; run = "layout floating"; }
      ];
      
      key-mapping.preset = "qwerty";
      gaps = {
        inner.horizontal = 2;
        inner.vertical = 2;
        outer.left = 0;
        outer.bottom = 0;
        outer.top = 0;
        outer.right = 0;
      };
      mode.main.binding = {
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
        alt-shift-space = "layout floating tiling";
        alt-f = "fullscreen";
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-a = "workspace A";
        alt-b = "workspace B";
        alt-c = "workspace C";
        alt-d = "workspace D";
        alt-e = "workspace E";
        alt-g = "workspace G";
        alt-i = "workspace I";
        alt-m = "workspace M";
        alt-n = "workspace N";
        alt-o = "workspace O";
        alt-p = "workspace P";
        alt-q = "workspace Q";
        alt-r = "workspace R";
        alt-s = "workspace S";
        alt-t = "workspace T";
        alt-u = "workspace U";
        alt-v = "workspace V";
        alt-w = "workspace W";
        alt-x = "workspace X";
        alt-y = "workspace Y";
        alt-z = "workspace Z";
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-a = "move-node-to-workspace A";
        alt-shift-b = "move-node-to-workspace B";
        alt-shift-c = "move-node-to-workspace C";
        alt-shift-d = "move-node-to-workspace D";
        alt-shift-e = "move-node-to-workspace E";
        alt-shift-g = "move-node-to-workspace G";
        alt-shift-i = "move-node-to-workspace I";
        alt-shift-m = "move-node-to-workspace M";
        alt-shift-n = "move-node-to-workspace N";
        alt-shift-o = "move-node-to-workspace O";
        alt-shift-p = "move-node-to-workspace P";
        alt-shift-q = "move-node-to-workspace Q";
        alt-shift-r = "move-node-to-workspace R";
        alt-shift-s = "move-node-to-workspace S";
        alt-shift-t = "move-node-to-workspace T";
        alt-shift-u = "move-node-to-workspace U";
        alt-shift-v = "move-node-to-workspace V";
        alt-shift-w = "move-node-to-workspace W";
        alt-shift-x = "move-node-to-workspace X";
        alt-shift-y = "move-node-to-workspace Y";
        alt-shift-z = "move-node-to-workspace Z";
        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
        cmd-h = [];
        cmd-alt-h = [];
        cmd-alt-right = "workspace --wrap-around next";
        cmd-alt-left = "workspace --wrap-around prev";
        alt-shift-semicolon = "mode service";
      };
      mode.service.binding = {
        esc = [ "reload-config" "mode main" ];
        r = [ "flatten-workspace-tree" "mode main" ];
        f = [ "layout floating tiling" "mode main" ];
        alt-shift-h = [ "join-with left" "mode main" ];
        alt-shift-j = [ "join-with down" "mode main" ];
        alt-shift-k = [ "join-with up" "mode main" ];
        alt-shift-l = [ "join-with right" "mode main" ];
      };
    };
  };

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
