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
    ".config/newsboat/bookmark.sh".source = scripts/newsboat/bookmark.sh;
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
        set notermguicolors
        colorscheme solarized

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
      extraLuaConfig = ''
        -- require('lazy').setup({
        --   {
        --     "dustinblackman/oatmeal.nvim",
        --     cmd = { "Oatmeal" },
        --     keys = {
        --         { "<leader>om", mode = "n", desc = "Start Oatmeal session" },
        --     },
        --   },
        -- }),

        return require("toggleterm").setup{
          -- size can be a number or function which is passed the current terminal
          function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end,
          open_mapping = [[<c-t>]],
          -- on_create = fun(t: Terminal), -- function to run when the terminal is first created
          -- on_open = fun(t: Terminal), -- function to run when the terminal opens
          -- on_close = fun(t: Terminal), -- function to run when the terminal closes
          -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
          -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
          -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
          hide_numbers = true, -- hide the number column in toggleterm buffers
          shade_filetypes = {},
          autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
          shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
          shading_factor = '-30', -- the percentage by which to lighten dark terminal background, default: -30
          shading_ratio = '-3', -- the ratio of shading factor for light/dark terminal background, default: -3
          start_in_insert = true,
          insert_mappings = true, -- whether or not the open mapping applies in insert mode
          terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
          persist_size = true,
          persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
          direction = 'horizontal',
          close_on_exit = true, -- close the terminal window when the process exits
          clear_env = false, -- use only environmental variables from `env`, passed to jobstart()
          auto_scroll = true, -- automatically scroll to the bottom on terminal output
          float_opts = {
            -- The border key is *almost* the same as 'nvim_open_win'
            -- see :h nvim_open_win for details on borders however
            -- the 'curved' border is a custom border type
            -- not natively supported but implemented in this plugin.
            border = 'double',
            -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
            -- width = <value>,
            -- height = <value>,
            -- row = <value>,
            -- col = <value>,
            -- title_pos = 'left' | 'center' | 'right', position of the title of the floating window
          },
          winbar = {
            enabled = false,
            name_formatter = function(term) --  term: Terminal
              return term.name
            end
          },
          responsiveness = {
            -- breakpoint in terms of `vim.o.columns` at which terminals will start to stack on top of each other
            -- instead of next to each other
            -- default = 0 which means the feature is turned off
            horizontal_breakpoint = 135,
          }
        },
      '';

      plugins = with pkgs.vimPlugins; [
        ale
        git-blame-nvim
        { plugin = neo-tree-nvim;
          config = ''
            nnoremap <leader>nt <cmd>Neotree source=filesystem position=left reveal=true toggle<cr>
          '';
        }
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
        { plugin = toggleterm-nvim;
          config = ''
            " set
            autocmd TermEnter term://*toggleterm#*
                  \ tnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>

            " By applying the mappings this way you can pass a count to your
            " mapping to open a specific window.
            " For example: 2<C-t> will open terminal 2
            nnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
            inoremap <silent><C-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

            "function _G.set_terminal_keymaps()
            "  local opts = {buffer = 0}
            "  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            "  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
            "  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            "  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            "  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            "  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            "  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
            "end
            "
            "-- if you only want these mappings for toggle term use term://*toggleterm#* instead
            "vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
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
        zoomwintab-vim
      ];
      vimAlias = true;
    };

    newsboat = {
      autoReload = true;
      enable = true;
      extraConfig = ''
        bookmark-cmd "~/.config/newsboat/bookmark.sh"
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
        {
          tags = [
            "terminal"
          ];
          url = "https://github.com/agarrharr/awesome-cli-apps/commits.atom";
        }
        {
          tags = [
            "terminal"
          ];
          url = "https://cli.club/rss.xml";
        }
        {
          tags = [
            "terminal"
          ];
          url = "https://selfh.st/rss/";
        }
      ];
    };

    pay-respects = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--alias"
        "fuck"
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
        kubernetes = {
          contexts = [
            {
              context_pattern = ".*test.*";
              context_alias = "test";
              style = "bold yellow";
              user_alias = "admin";
            }
            {
              context_pattern = ".*prod.*";
              context_alias = "PROD";
              style = "bold red";
              user_alias = "admin";
            }
          ];
          disabled = false;
        };
        line_break.disabled = true;
      };
    };

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
