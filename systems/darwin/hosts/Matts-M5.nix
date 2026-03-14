{ lib, ... }:

{
  # Apple Silicon configuration
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # Enable Rosetta for x86_64 compatibility
  nix-homebrew.enableRosetta = true;
}
