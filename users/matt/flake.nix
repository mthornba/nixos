{
  description = "Home Manager configuration of matt";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ekphos.url = "github:hanebox/ekphos";
    ekphos.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ekphos, ... }:
    let
      mkHome = system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit ekphos; };
          modules = [ ./home.nix ];
        };
    in {
      # Home Manager selects the configuration matching "${user}@${host}"
      # when no flake attribute is specified. Provide per-host configs with
      # explicit systems to avoid relying on builtins.currentSystem.
      homeConfigurations = {
        # NixOS
        "matt@neon" = mkHome "x86_64-linux";
        
        # Intel MacBook Pro
        "matt@Matts-MacBook-Pro" = mkHome "x86_64-darwin";
        "matt@Matts-MacBook-Pro.local" = mkHome "x86_64-darwin";
        
        # M5 MacBook (Apple Silicon)
        "matt@Matts-M5" = mkHome "aarch64-darwin";
        "matt@Matts-M5.local" = mkHome "aarch64-darwin";
      };
    };
}
