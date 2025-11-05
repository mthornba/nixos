{
  description = "neon System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = { nixpkgs, ... }:
  let
    # Keep Linux system pin for NixOS host build.
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    lib = nixpkgs.lib;

    # Helper to expose apps for both Linux and Darwin so we can `nix run`.
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
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
              DARWIN_FLAKE_REF="$FLAKE_ROOT/systems/Matts-MacBook-Pro#Matts-MacBook-Pro"
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
