{
  description = "Home Manager configuration of matt";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-25_11.url = "github:NixOS/nixpkgs/nixos-25.11";
    clin.url = "github:reekta92/clin-rs";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixpkgs-25_11, home-manager, nur, clin, ... }:
    let
      mkHome = system:
        let 
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ 
              nur.overlays.default
              # Overlay to provide unstable packages and fix broken stable packages
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
                # pipx 1.8.0 in stable has cosmetic test failures (spacing in package specifier
                # assertions) that don't affect functionality. Skip tests to allow it to build.
                pipx = prev.pipx.overrideAttrs (_: { doInstallCheck = false; });
                # intelli-shell 3.4.1 has a test_default_config snapshot mismatch that doesn't
                # affect functionality (AI prompt text changed but snapshot wasn't updated).
                intelli-shell = prev.intelli-shell.overrideAttrs (_: { doCheck = false; });
                # qtwebengine 6.11.0 fails to compile on aarch64-darwin in 26.05. Pin to 25.11
                # where it builds successfully.
                qutebrowser = (import nixpkgs-25_11 {
                  inherit system;
                  config.allowUnfree = true;
                }).qutebrowser;
                # Pin to 25.11 for compatibility with self-hosted Vaultwarden instance.
                bitwarden-cli = (import nixpkgs-25_11 {
                  inherit system;
                  config.allowUnfree = true;
                }).bitwarden-cli;
              })
            ];
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { clin-pkg = clin.packages.${system}.default; };
          modules = [ ./home.nix ];
        };
    in {
      # Home Manager selects the configuration matching "${user}@${host}"
      # when no flake attribute is specified. Provide per-host configs with
      # explicit systems to avoid relying on builtins.currentSystem.
      homeConfigurations = {
        # NixOS
        "matt@neon" = mkHome "x86_64-linux";
        
        # Intel MacBook Pro (various hostname suffixes)
        "matt@Matts-MacBook-Pro" = mkHome "x86_64-darwin";
        "matt@Matts-MacBook-Pro.local" = mkHome "x86_64-darwin";
        "matt@Matts-MacBook-Pro.home.arpa" = mkHome "x86_64-darwin";
        
        # M5 MacBook (Apple Silicon, various hostname suffixes)
        "matt@Matts-M5" = mkHome "aarch64-darwin";
        "matt@Matts-M5.local" = mkHome "aarch64-darwin";
        "matt@Matts-M5.home.arpa" = mkHome "aarch64-darwin";
      };
    };
}
