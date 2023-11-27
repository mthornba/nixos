{ config, pkgs, ... }:

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
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

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
  home.packages = with pkgs; [
    # cli apps
    bat
    buku
    htop
    keychain
    lsd
    navi
    nnn
    ranger
    silver-searcher
    tldr
    # graphical apps
    discord # unfree
    emacs
    freecad
    kitty
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

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

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
  programs = {

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

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    kitty = {
      font = {
        name = "Hack Nerd Font Mono";
      };
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

    thefuck.enable = true;

    zsh = {
      enable = true;
      enableAutosuggestions = true;
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
        ll = "lsd -lg";
        lla = "lsd -lAg";
        lst = "lsd --tree";
        lsat = "lsd -a --tree";
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

  };

}
