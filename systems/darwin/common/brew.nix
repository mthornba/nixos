{ config, pkgs, lib, ... }:

{
  users.users.matt = {
    name = "matt";
    home = "/Users/matt";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;

    # List of Homebrew formulae to install
    brews = [
      "azure-cli"
      "ekphos"
      "mas"
      "oatmeal"
      "pvetui"
    ];
    
    casks = [
      "logseq"
      "orbstack"
      "plexamp"
      "unnaturalscrollwheels"
      "utm"
      "vivaldi"
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
      # Intel-only casks
      "virtualbox"
    ];
    
    taps = builtins.attrNames config.nix-homebrew.taps;
    
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = false; # make darwin-rebuild switch idempotent
      upgrade = false;
    };

    # Mac App Store apps - commented out due to SSH permission issues
    # Install manually via App Store or grant Full Disk Access
    masApps = {
      "azure-vpn-client" = 1553936137;
      "bitwarden" = 1352778147;
      "Microsoft Excel" = 462058435;
      "Microsoft Outlook" = 985367838;
      "Microsoft PowerPoint" = 462062816;
      "OneDrive" = 823766827;
      "wireguard" = 1451685025;
    };
  };
}
