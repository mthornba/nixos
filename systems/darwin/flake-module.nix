{ inputs, ... }:

let
  mkDarwinSystem = hostname: inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ./common
      ./common/brew.nix
      ./hosts/${hostname}.nix
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          user = "matt";
          
          # Optional: Declarative tap management
          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
            "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
            "homebrew/homebrew-services" = inputs.homebrew-services;
            "dustinblackman/homebrew-tap" = inputs.homebrew-dustinblackman;
            "devnullvoid/homebrew-pvetui" = inputs.homebrew-devnullvoid;
          };

          mutableTaps = false;
        };
      }
    ];
  };
in
{
  # Intel MacBook Pro
  "Matts-MacBook-Pro" = mkDarwinSystem "Matts-MacBook-Pro";
  
  # M5 MacBook
  "Matts-M5" = mkDarwinSystem "Matts-M5";
}
