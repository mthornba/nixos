{ config, pkgs, system, ... }:

let
  isLinux = system == "x86_64-linux";
  isDarwin = system == "x86_64-darwin";

  hostname =
    if isLinux then builtins.readFile "/etc/hostname"
    else if isDarwin then builtins.exec [ "/usr/sbin/scutil" "--get" "LocalHostName" ]
    else throw "Unsupported system: ${builtins.currentSystem}";

  isNeon = hostname == "neon";

  # dconf settings
  dconfSettingsCommon = {
  };

  dconfSettingsNeon = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  dconfSettingsOther = {
    # dconf settings specific to other hosts
  };

  # packages
  pkgsCommon = with pkgs; [
    # common cli apps
    bat
    buku
    file
    htop
    ipcalc
    jq
    keychain
    kubectl
    lsd
    navi
    ranger
    silver-searcher
    terraform # unfree
    tldr
    unzip
    wtf
    zip

    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

  ];

  pkgsNeon = with pkgs; [
    # packages specific to Neon
    discord # unfree
    emacs
    freecad
    logseq
    nyxt
    plexamp # unfree
    prusa-slicer
    signal-desktop
    solaar
    spotify # unfree
    syncthing
    vivaldi # unfree
    vlc
    vscode # unfree
  ];

  pkgsOther = with pkgs; [
    # packages specific to other hosts
    # pkgs.hello
  ];

  # programs
  programsCommon = {

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    gh = {
      enable = true;
    };

    starship = {
      enable = true;
      # custom settings
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      defaultKeymap = "viins";

      #TODO: remove plugin
      #syntaxHighlighting = {
      #  enable = true;
      #  styles = {
      #    brackets = "bg=blue"
      #  };
      #};

      historySubstringSearch = {
        enable = true;
        #TODO: remove plugin
        #searchDownKey = [
        #  "j"
        #  "[B"
        #];
        #searchUpKey = [
        #  "k"
        #  "[A"
        #];
      };

      shellAliases = {
        # buku
        b = "buku --np";
        # k8s
        k = "kubectl";
        # lsd
        ll = "lsd -lg";
        lla = "lsd -lAg";
        lst = "lsd --tree";
        lsat = "lsd -a --tree";
        # kitty
        icat = "kitty +kitten icat";
        kssh = "kitty +kitten ssh";
      };

      zplug = {
        enable = true;
        plugins = [
          { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/ag"; tags = [ from:oh-my-zsh ]; }
          { name = "zdharma-continuum/fast-syntax-highlighting"; }
          { name = "zsh-users/zsh-history-substring-search"; tags = [ as:plugin ]; }
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "marzocchi/zsh-notify"; }
          { name = "zdharma-continuum/zsh-diff-so-fancy"; }
          { name = "jimeh/zsh-peco-history"; }
        ];
      };

      initExtra = ''
        # bind arrow keys to zsh-history-substring-search functions
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
        bindkey -M vicmd '^[OA' history-substring-search-up
        bindkey -M vicmd '^[OB' history-substring-search-down
        bindkey -M viins '^[OA' history-substring-search-up
        bindkey -M viins '^[OB' history-substring-search-down
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

  };

  programsNeon = {

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName  = "Matt Thornback";
      userEmail = "matt.thornback@gmail.com";
      extraConfig = {
        credential.helper = "${
            pkgs.git.override { withLibsecret = true; }
          }/bin/git-credential-libsecret";
      };
    };

    kitty = {
      enable = true;
      shellIntegration = {
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
      font = {
        name = "Hack Nerd Font Mono";
        size = 12;
      };
      keybindings = {
        "shift+cmd+v" = "paste_from_buffer a1";
        "ctrl+alt+enter" = "launch --cwd=current";
        "ctrl+alt+z" = "toggle_layout stack";
      };
      settings = {
        url_style = "dashed";
        copy_on_select = "a1";
        mouse_map = "right press ungrabbed paste_from_buffer a1";
        enable_audio_bell = "no";
        visual_bell_duration = "0.1";
        bell_on_tab = "\"🔔 \"";
        tab_bar_style = "fade";
        hide_window_decorations = "no";
      };
      theme = "Solarized Dark";
    };

    thefuck.enable = true;

  };

  programsOther = {};

in
{
  # From https://github.com/Misterio77/nix-starter-configs/blob/972935c1b35d8b92476e26b0e63a044d191d49c3/minimal/home-manager/home.nix#L19:
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Set GNOME Dark Style
  dconf.settings = dconfSettingsCommon // (if isNeon then dconfSettingsNeon else dconfSettingsOther);

  fonts.fontconfig.enable = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "matt";
  home.homeDirectory = "/home/matt";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    pkgsCommon ++
    (if isNeon then pkgsNeon
    else if isMacbook then pkgsMacbook
    else pkgsOther);

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/matt/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Programs
  programs = programsCommon // (if isNeon then programsNeon else programsOther);

}
