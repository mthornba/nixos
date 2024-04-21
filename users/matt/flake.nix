{
  description = "Home Manager configuration of matt";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      hostnames = {
        neon = "x86_64-linux";
        # Add more hostnames and their corresponding systems here
      };
    in
      builtins.listToAttrs (map (hostname: {
        name = hostname;
        value = let
          system = hostnames.${hostname};
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          homeConfigurations."matt" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            extraSpecialArgs = {
              inherit system;
            };

            modules = [ ./home.nix ];
          };
        };
      }) (builtins.attrNames hostnames));

}
