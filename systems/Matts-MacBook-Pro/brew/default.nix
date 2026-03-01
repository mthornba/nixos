{ config, pkgs, lib, ... }:

let
  user = "matt";
in
{
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew
    enable = true;

    # List of Homebrew formulae to install
    brews = [
      "azure-cli"
      "oatmeal"
      "pvetui"
    ];
    casks = pkgs.callPackage ./casks.nix {};
    taps = builtins.attrNames config.nix-homebrew.taps;
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = false; # make darwin-rebuild switch idempotent
    };

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "azure-vpn-client" = 1553936137;
      "bitwarden" = 1352778147;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "wireguard" = 1451685025;
    };
  };
}
