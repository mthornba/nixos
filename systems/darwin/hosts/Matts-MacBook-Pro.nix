{ lib, ... }:

{
  # Intel-specific configuration
  nixpkgs.hostPlatform = "x86_64-darwin";
  
  # No Rosetta needed on Intel
  nix-homebrew.enableRosetta = false;
}
