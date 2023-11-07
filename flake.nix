{
  description = "neon System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      neon = lib.nixosSystem {
        inherit system;

        modules = [
          ./systems/neon/configuration.nix
        ];
      };
    };
  };
}
