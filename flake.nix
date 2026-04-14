{
  description = "neon System Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-dustinblackman = { url = "github:dustinblackman/homebrew-tap"; flake = false; };
    homebrew-devnullvoid = { url = "github:devnullvoid/homebrew-pvetui"; flake = false; };
    homebrew-services = { url = "github:homebrew/homebrew-services"; flake = false; };
    homebrew-johnsideserf = { url = "github:johnsideserf/homebrew-siggy"; flake = false; };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = { nixpkgs, nix-darwin, ... } @ inputs:
  let
    # Keep Linux system pin for NixOS host build.
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    lib = nixpkgs.lib;

    # Helper to expose apps for both Linux and Darwin so we can `nix run`.
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: lib.genAttrs supportedSystems (s: f s);
  in {
    nixosConfigurations = {
      neon = lib.nixosSystem {
        inherit system;

        modules = [
          ./systems/neon/configuration.nix
        ];
      };
    };

    # Darwin configurations for macOS systems
    darwinConfigurations = import ./systems/darwin/flake-module.nix { inherit inputs; };

    # Unified entrypoint: `nix run .` will detect OS and rebuild the right host
    # (NixOS vs. nix-darwin) and then apply Home Manager from users/matt.
    apps = forAllSystems (sys:
      let
        pkgsFor = import nixpkgs { system = sys; };
        script = pkgsFor.writeShellScriptBin "switch" ''
          set -euo pipefail

          OS="$(uname -s)"
          # Resolve repo root even when invoked from a subdir
          if command -v git >/dev/null 2>&1; then
            FLAKE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
          else
            FLAKE_ROOT="$(pwd)"
          fi

          # If caller exports NIXPKGS_ALLOW_BROKEN=1, run flake commands impure
          if [ "''${NIXPKGS_ALLOW_BROKEN:-}" = "1" ]; then
            IMPURE_FLAG="--impure"
          else
            IMPURE_FLAG=""
          fi

          case "$OS" in
            Darwin)
              # Detect hostname and use appropriate darwin configuration
              HOSTNAME="$(hostname -s)"
              DARWIN_FLAKE_REF="$FLAKE_ROOT#$HOSTNAME"
              echo "+ sudo darwin-rebuild switch $IMPURE_FLAG --flake \"$DARWIN_FLAKE_REF\""
              sudo darwin-rebuild switch $IMPURE_FLAG --flake "$DARWIN_FLAKE_REF"
              ;;
            Linux)
              if [ -f /etc/NIXOS ]; then
                NIXOS_FLAKE_REF="$FLAKE_ROOT#neon"
                echo "+ sudo nixos-rebuild switch $IMPURE_FLAG --flake \"$NIXOS_FLAKE_REF\""
                sudo nixos-rebuild switch $IMPURE_FLAG --flake "$NIXOS_FLAKE_REF"
              else
                echo "Detected Linux but not NixOS (missing /etc/NIXOS)." >&2
                exit 1
              fi
              ;;
            *)
              echo "Unsupported OS: $OS" >&2
              exit 1
              ;;
          esac

          if command -v home-manager >/dev/null 2>&1; then
            HM_SELECTOR="$(whoami)@$(hostname -s)"
            HM_FLAKE_REF="$FLAKE_ROOT/users/matt#$HM_SELECTOR"
            echo "+ home-manager switch $IMPURE_FLAG --flake \"$HM_FLAKE_REF\""
            home-manager switch $IMPURE_FLAG --flake "$HM_FLAKE_REF"
          else
            echo "home-manager not found on PATH; skipping user switch" >&2
          fi
        '';
      in {
        default = {
          type = "app";
          program = "${script}/bin/switch";
        };
        switch = {
          type = "app";
          program = "${script}/bin/switch";
        };
      }
    );
  };
}
