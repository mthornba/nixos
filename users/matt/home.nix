{ config, lib, pkgs, ... }:

let
  defaultImports = [
    ./modules/taskwarrior.nix
    ./modules/palitronica.nix
  ];
in
{

  imports = defaultImports;

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

  fonts.fontconfig.enable = true;
  # fonts.packages = [
  #   pkgs.nerd-fonts.hack
  # ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "matt";
  home.homeDirectory = "/Users/matt";

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
    browsh
    buku
    carl
    ddgr
    dos2unix
    fd
    file
    gfold
    gita
    gitnr
    glow
    gurk-rs
    gnupg
    hoard
    htop
    ipcalc
    jless
    jq
    jqp
    keychain
    lsd
    ncdu
    nerd-fonts.hack
    nmap
    pv
    ripgrep
    serpl
    silver-searcher
    sshs
    termscp
    tldr
    unrar
    unzip
    wtfutil
    zip
    # graphical apps
    # logseq
    # vivaldi # unfree
    slack
    vscode # unfree

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

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
    # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # symlink to the Nix store copy.
    ".config/wtf/config.yml".source = dotfiles/wtf/config.yml;
    "zellij/config.kdl".source = dotfiles/zellij/config.kdl;

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
    BUKU_COLORS = "FCexd";
  };

  # Programs
  programs = {

    aerc = {
      enable = true;
#      extraConfig = {
#        "text/html" = "! w3m -T text/html -I UTF-8";
#      };
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        inline_height = 15;
        show_preview = true;
        style = "auto";
        workspaces = true;
      };
    };

    dircolors.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    firefox = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = false;
    };

    gh = {
      enable = true;
    };

    git = {
      enable = true;
      extraConfig = {
        credential.helper = "${
            pkgs.git.override { withLibsecret = true; }
          }/bin/git-credential-libsecret";
        init = {
          templateDir = "~/.git-template";
          defaultBranch = "main";
        };
      };
      ignores = [
        "*.DS_Store"
        "*.swp"
      ];
      userName  = "Matt Thornback";
      userEmail = "matt.thornback@palitronica.com";
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

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
        selection_foreground = "none";
        selection_background = "none";
        macos_option_as_alt = "left";
        # include = "~/.config/kitty/current-theme.conf";
      };
      themeFile = "Solarized8_Dark";
    };

    navi = {
      enable = true;
      settings = {
        finder = {
          command = "fzf";
        };
        shell = {
          command = "zsh";
        };
      };
    };

    neovim = {
      defaultEditor = true;
      enable = true;
      extraConfig =
        ''
        set number
        colorscheme solarized8_dark

        " Set indentation
        " Use spaces instead of tabs
        set expandtab
        " Number of spaces to use for a tab
        set tabstop=2
        " Number of spaces to use for autoindenting
        set shiftwidth=2
        " Enable autoindenting
        set autoindent
        " Enable smart indenting
        set smartindent
        " Soft tabstop (optional, but often helpful)
        set softtabstop=2
        '';
        extraLuaConfig =
        ''
        return require('lazy').setup({
          {
            "dustinblackman/oatmeal.nvim",
            cmd = { "Oatmeal" },
            keys = {
                { "<leader>om", mode = "n", desc = "Start Oatmeal session" },
            },
            opts = {
                backend = "gemini",
                model = "gemini-1.5.flash:latest",
            },
          },
        })
        '';
      plugins = with pkgs.vimPlugins; [
        ale
        git-blame-nvim
        { plugin = nerdtree;
          config = "nmap <F2> :NERDTreeToggle<CR>";
        }
        { plugin = lazy-nvim;
        }
        nerdtree-git-plugin
        telescope-fzf-native-nvim
        { plugin = telescope-nvim;
          config = ''
            " Find files using Telescope command-line sugar.
            nnoremap <leader>ff <cmd>Telescope find_files<cr>
            nnoremap <leader>fg <cmd>Telescope live_grep<cr>
            nnoremap <leader>fb <cmd>Telescope buffers<cr>
            nnoremap <leader>fh <cmd>Telescope help_tags<cr>
          '';
        }
        vim-airline
        { plugin = vim-airline-themes;
          config = ''
            let g:airline_theme='solarized_flood'
            let g:airline_solarized_bg='dark'
            let g:airline_powerline_fonts = 1

            if !exists('g:airline_symbols')
              let g:airline_symbols = {}
            endif

            " unicode symbols
            let g:airline_left_sep = '»'
            let g:airline_left_sep = '▶'
            let g:airline_right_sep = '«'
            let g:airline_right_sep = '◀'
            let g:airline_symbols.crypt = '🔒'
            let g:airline_symbols.linenr = '☰'
            let g:airline_symbols.linenr = '␊'
            let g:airline_symbols.linenr = '␤'
            let g:airline_symbols.linenr = '¶'
            let g:airline_symbols.maxlinenr = ' '
            let g:airline_symbols.maxlinenr = '㏑'
            let g:airline_symbols.branch = '⎇'
            let g:airline_symbols.paste = 'ρ'
            let g:airline_symbols.paste = 'Þ'
            let g:airline_symbols.paste = '∥'
            let g:airline_symbols.spell = 'Ꞩ'
            let g:airline_symbols.notexists = 'Ɇ'
            let g:airline_symbols.whitespace = 'Ξ'

            " powerline symbols
            let g:airline_left_sep = ''
            let g:airline_left_alt_sep = ''
            let g:airline_right_sep = ''
            let g:airline_right_alt_sep = ''
            let g:airline_symbols.branch = ''
            let g:airline_symbols.readonly = ''
            let g:airline_symbols.linenr = '☰'
            let g:airline_symbols.maxlinenr = ''
          '';
        }
        vim-colors-solarized
        vim-colorschemes
        vim-fugitive
        vim-gitgutter
        { plugin = vim-terraform;
          config = ''
            let g:terraform_fmt_on_save=1
            let g:terraform_align=1
          '';
        }
        vim-terraform-completion
        xterm-color-table-vim
      ];
      vimAlias = true;
    };

    newsboat = {
      autoReload = true;
      enable = true;
      extraConfig = ''
        color background color244 default
        color listnormal color244 default
        color listfocus color15 color136
        color listnormal_unread color33 default
        color listfocus_unread color15 color136
        color info color244 color235
        color article color15 default
        highlight article "^(Title):.*$" color5  default
        highlight article "https?://[^ ]+" blue default
        highlight article "\\[image\\ [0-9]+\\]" green default
      '';
      urls = [
        {
          tags = [
            "terminal"
          ];
          url = "https://terminaltrove.com/new.xml";
        }
        {
          tags = [
            "tech"
          ];
          url = "https://news.ycombinator.com/rss";
        }
        {
          tags = [
            "tech"
          ];
          url = "https://lobste.rs/rss";
        }
      ];
    };

    ranger = {
      enable = true;
      settings = {
        preview_images_method = "kitty";
      };
    };

    starship = {
      enable = true;
      # custom settings
      settings = {
        add_newline = true;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    thefuck.enable = true;

    tmux = {
      enable = true;
      keyMode = "vi";
      reverseSplit = true;
      terminal = "xterm-256color";
      plugins = with pkgs; [
        tmuxPlugins.tilish
      ];
    };

    vim = {
      defaultEditor = true;
      enable = false;
      extraConfig =
        ''
        colorscheme solarized8_dark
        nmap <F2> :NERDTreeToggle<CR>
        '';
      plugins = with pkgs.vimPlugins; [
        nerdtree
        nerdtree-git-plugin
        vim-colors-solarized
        vim-colorstepper
        vim-colorschemes
        vim-gitgutter
        vim-terraform-completion
        xterm-color-table-vim
      ];
      settings = {
        modeline = true;
        number = true;
      };
    };

    zellij = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;

      autosuggestion = {
        enable = true;
        highlight = "fg=#52676f,bg=dim";
      };

      defaultKeymap = "viins";

      enableCompletion = true;

      sessionVariables = {
        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND = "bg=green,fg=black,bold";
        MANPAGER = "bat --plain --language man";
      };

      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
        styles = {
          alias = "fg=blue";
        };
      };

      history = {
        append = true;
        extended = true;
        ignoreAllDups = true;
        ignoreDups = false;
        share = true;
      };

      historySubstringSearch = {
        enable = true;
        searchDownKey = [
          "^[OB"
        ];
        searchUpKey = [
          "^[OA"
        ];
      };

      initContent = let
        zshConfigEarlyInit = lib.mkOrder 500 "# Early";
        zshConfigBeforeCompInit = lib.mkOrder 550 "# BeforeCompInit";
        zshConfig = lib.mkOrder 1000 ''
          # shellcheck disable=SC2034,SC2153,SC2086,SC2155
          # Above line is because shellcheck doesn't support zsh, per
          # https://github.com/koalaman/shellcheck/wiki/SC1071, and the ignore: param in
          # ludeeus/action-shellcheck only supports _directories_, not _files_. So
          # instead, we manually add any error the shellcheck step finds in the file to
          # the above line ...
          
          # Source this in your ~/.zshrc
          autoload -U add-zsh-hook
          
          _hoard_list(){
            emulate -L zsh
            zle -I
          
            echoti rmkx
              # Similar to bash plugin in hoard.bash
            output=$(hoard --autocomplete list 3>&1 1>&2 2>&3)
            echoti smkx
          
            if [[ -n $output ]] ; then
              LBUFFER=$output
            fi
          
            zle reset-prompt
          }
          
          zle -N _hoard_list_widget _hoard_list
          
          if [[ -z $HOARD_NOBIND ]]; then
            bindkey '^h' _hoard_list_widget
          
            # depends on terminal mode
            #bindkey '^[[A' _hoard_list_widget
            #bindkey '^[OA' _hoard_list_widget
          fi

          # Completion styling
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

          # Make "kubecolor" borrow the same completion logic as "kubectl"
          compdef kubecolor=kubectl

          # krew
          export PATH="''\${KREW_ROOT:-''\$HOME/.krew}/bin:$PATH"

          # display Vault secrets
          showCreds() {
            vault kv get -format=json -mount="''\${1}" "''\${2}" | \
            jq '.data.data | to_entries|map("\(.key)='"'"'\(.value|tostring)'"'"'")|.[]' -r
          }

          # source Vault secrets into shell environment
          getCreds() {
            eval $(vault kv get -format=json -mount="''\${1}" "''\${2}" | \
            jq '.data.data | to_entries|map("export \(.key)='"'"'\(.value|tostring)'"'"'")|.[]' -r)
          }
        '';
        zshConfigLate = lib.mkOrder 1500 "# Late";
      in
        lib.mkMerge [ zshConfigEarlyInit zshConfigBeforeCompInit zshConfig zshConfigLate ];

      shellAliases = {
        # buku
        b = "buku --np";
        # k8s
        k = "kubecolor";
        kdr = "kubectl --dry-run=client -o yaml";
        # lsd
        ll = "lsd -lg";
        lla = "lsd -lAg";
        llatr = "lsd -lAgtr";
        lst = "lsd --tree";
        lsat = "lsd -a --tree";
        # kitty
        icat = "kitty +kitten icat";
        kssh = "kitty +kitten ssh";
        # split path
        ppath = "sed -e \"s/:/\\n/g\" <<< \$PATH";
        # taskwarrior
        t = "task";
        # terraform
        tf = "terraform";
        tfd = "terraform-docs";
        tg = "terragrunt";
      };

      zplug = {
        enable = false;
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

      plugins = [
        {
          name = "ohmyzsh-lib-git";
          file = "lib/git.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "ohmyzsh";
            repo = "ohmyzsh";
            rev = "master";
            sha256 = "TyFy7bHiOuD72Kv6sWbu71crftIF2wqD9Gaege1iVgI=";
          };
        }
        {
          name = "ohmyzsh-git";
          file = "plugins/git/git.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "ohmyzsh";
            repo = "ohmyzsh";
            rev = "master";
            sha256 = "TyFy7bHiOuD72Kv6sWbu71crftIF2wqD9Gaege1iVgI=";
          };
        }
      ];

    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

  };

}
