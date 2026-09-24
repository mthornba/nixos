{ lib, ... }:

{
  # Apple Silicon configuration
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  # Disable nix-darwin's nix daemon management when using Determinate installer
  # M5 uses Determinate Systems installer which manages the daemon and nix.conf
  nix.enable = false;
  
  # Rosetta/Intel Homebrew prefix (/usr/local) is not needed: the only
  # x86_64-gated cask (virtualbox) never applies to Apple Silicon.
  nix-homebrew.enableRosetta = false;
}
