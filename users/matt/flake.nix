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
        "matt@neon" = mkHome "x86_64-linux";
        "matt@Matts-MacBook-Pro" = mkHome "x86_64-darwin";
        # Some environments (e.g., macOS) expose HOSTNAME with a .local suffix
        # so make the default selector work without specifying an attribute.
        "matt@Matts-MacBook-Pro.local" = mkHome "x86_64-darwin";
      };
    };
}
