{ config, pkgs, lib, ... }:

let
  # Derive short tap names for `brew trust` from the declarative tap set.
  # Filters out official homebrew/* taps (auto-trusted) and strips the
  # "homebrew-" prefix from repo names (e.g. "herald-email/homebrew-herald"
  # → "herald-email/herald").
  thirdPartyTaps = lib.filter (t: !(lib.hasPrefix "homebrew/" t))
    (builtins.attrNames config.nix-homebrew.taps);
  tapTrustNames = map (t:
    let
      parts = lib.splitString "/" t;
      user  = builtins.elemAt parts 0;
      repo  = lib.removePrefix "homebrew-" (builtins.elemAt parts 1);
    in "${user}/${repo}"
  ) thirdPartyTaps;
in
{
  # Trust all third-party taps before brew bundle runs (Homebrew 4.5+ requires
  # explicit trust for non-homebrew/* taps). Script name "brewTrust" sorts
  # before "homebrew" so it runs first during activation.
  system.activationScripts.brewTrust.text = ''
    for BREW in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [ -x "$BREW" ] || continue
      ${lib.concatMapStrings (tap: ''
        "$BREW" trust "${tap}" 2>/dev/null || true
      '') tapTrustNames}
      break
    done
  '';

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
      "herald"
      "mas"
      "oatmeal"
      "purple"
      "pvetui"
      "siggy"
      "splashboard"
    ];
    
    casks = [
      "browserino"
      "ollama-app"
      "finicky"
      "logseq"
      "orbstack"
      "plexamp"
      "scroll-reverser"
      "truetree"
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
