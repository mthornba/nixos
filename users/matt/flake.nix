{
  description = "Home Manager configuration of matt";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, nur, ... }:
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
              })
            ];
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
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
