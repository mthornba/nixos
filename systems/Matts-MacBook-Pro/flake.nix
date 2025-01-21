{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-services, home-manager, nixpkgs }:
  let
    user = "matt";
    configuration = { pkgs, ... }: {

      nixpkgs = {
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      imports = [
        ./brew
      ];

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        ansible
        curl
        darwin.iproute2mac
        lima
        qemu
        raycast
        vim
        wget
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      security.pam.enableSudoTouchIdAuth = true;

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      system.defaults = {
        dock = {
          appswitcher-all-displays = true;
          autohide = true;
          persistent-apps = [
            "/Applications/Vivaldi.app"
          ];
          persistent-others = [
            "/Users/${user}/Applications"
          ];
          wvous-bl-corner = 11; # Launchpad
          wvous-br-corner = 2; # Mission Control

        };
        NSGlobalDomain = {
          _HIHideMenuBar = false; # autohide menu bar
          AppleInterfaceStyle = "Dark";
          # Disable press and hold for diacritics (to allow holding down vim keys in vscode)
          ApplePressAndHoldEnabled = false;
          AppleShowAllFiles = true; # show hidden files
          KeyRepeat = 2; # how fast keys repeat
          NSAutomaticCapitalizationEnabled = false;
          NSWindowShouldDragOnGesture = true; # drag windows from anywhere
        };
        LaunchServices.LSQuarantine = false;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Matts-MacBook-Pro
    darwinConfigurations."Matts-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = false;

            # User owning the Homebrew prefix
            user = "${user}";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "homebrew/homebrew-services" = homebrew-services;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Matts-MacBook-Pro".pkgs;
  };
}
