{ lib, ... }:

{
  # Apple Silicon configuration
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # Disable nix-darwin's nix daemon management when using Determinate installer
  # M5 uses Determinate Systems installer which manages the daemon and nix.conf
  nix.enable = false;
  
  # Enable Rosetta for x86_64 compatibility
  nix-homebrew.enableRosetta = true;
}
