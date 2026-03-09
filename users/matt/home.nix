{ config, lib, pkgs, ekphos, ... }:

let
  defaultImports = [
    ./modules/neovim.nix
    ./modules/palitronica.nix
    ./modules/taskwarrior.nix
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
      # Darwin stub for postgresql test hook so pgcli builds without allowing broken
      (final: prev:
        if prev.stdenv.isDarwin then
          let
            stub = prev.writeTextDir "nix-support/setup-hook" ''
              # no-op postgresql test hook on darwin
            '';
          in {
            postgresqlTestHook = stub;
            "postgresql-test-hook" = stub;
          }
        else {}
      )

      # Build ekphos from the upstream flake source, avoiding the removed
      # darwin.apple_sdk_11_0 stub by using current SDK frameworks.
      (final: prev:
        let
          src = ekphos;
        in {
          ekphos = final.rustPlatform.buildRustPackage {
            pname = "ekphos";
            version = "0.15.0";
            src = src;
            cargoLock.lockFile = "${src}/Cargo.lock";
            nativeBuildInputs = with final; [ pkg-config ];
            buildInputs =
              with final;
              lib.optionals stdenv.isDarwin [
                darwin.apple_sdk.frameworks.AppKit
              ]
              ++ lib.optionals stdenv.isLinux [
                xorg.libxcb
                xorg.libX11
                xorg.libXcursor
                xorg.libXrandr
                xorg.libXi
              ];
            meta = with final.lib; {
              description = "A lightweight, fast, terminal-based markdown research tool";
              homepage = "https://github.com/hanebox/ekphos";
              license = licenses.mit;
              mainProgram = "ekphos";
              platforms = platforms.linux ++ platforms.darwin;
            };
          };
        })
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
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/matt" else "/home/matt";

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
    aichat
    bat
    browsh
    buku
    carl
    copilot-language-server
    curlie
    ddgr
    delta
    docker-client  # Docker CLI for use with OrbStack
    doggo
    dos2unix
    ekphos
    fd
    file
    gfold
    gita
    frogmouth
    ghq
    github-copilot-cli
    gitnr
    glow
    gurk-rs
    gnupg
    htop
    ipcalc
    jless
    jq
    jqp
    keychain
    lsd
    ncdu
    nerd-fonts.fira-code
    nmap
    pv
    ripgrep
    serpl
    silver-searcher
    so
    sshs
    termscp
    tldr
    tmuxp
    unrar
    unzip
    viddy
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
    (pkgs.writeShellScriptBin "termcolors" (builtins.readFile ./dotfiles/scripts/termcolors))

  ];

  # Tip: add OS-specific packages when needed, e.g.:
  # home.packages = (with pkgs; [
  #   ripgrep jq
  # ])
  # ++ lib.optionals pkgs.stdenv.isDarwin [ iterm2 ]
  # ++ lib.optionals pkgs.stdenv.isLinux [ xclip ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # symlink to the Nix store copy.
    ".config/kitty/sessions".source = dotfiles/kitty/sessions;
    ".config/newsboat/bookmark.sh".source = scripts/newsboat/bookmark.sh;
    ".config/wtf/config.yml".source = dotfiles/wtf/config.yml;
    ".config/zellij/config.kdl".source = dotfiles/zellij/config.kdl;
    ".config/tmux-powerline/config.sh".source = dotfiles/tmux-powerline/config.sh;
    ".config/tmux-powerline/themes/nixos-minimal.sh".source = dotfiles/tmux-powerline/themes/nixos-minimal.sh;
    ".tmuxp/code.yml".source = dotfiles/tmuxp/code.yml;
    ".tmuxp/dashboard.yml".source = dotfiles/tmuxp/dashboard.yml;
    ".tmuxp/kubernetes.yml".source = dotfiles/tmuxp/kubernetes.yml;

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

    aerospace = {
      enable = true;
      launchd.enable = true;
      settings = {
        config-version = 2;
        after-startup-command = [ ];
        start-at-login = false;
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        accordion-padding = 30;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        automatically-unhide-macos-hidden-apps = false;
        
        # Windows that should always float
        on-window-detected = [
          # System Preferences/Settings
          { "if" = { app-id = "com.apple.systempreferences"; }; run = "layout floating"; }
          # Calculator
          { "if" = { app-id = "com.apple.calculator"; }; run = "layout floating"; }
          # Activity Monitor
          { "if" = { app-id = "com.apple.ActivityMonitor"; }; run = "layout floating"; }
          # Archive Utility
          { "if" = { app-id = "com.apple.archiveutility"; }; run = "layout floating"; }
          # Software Update
          { "if" = { app-id = "com.apple.SoftwareUpdate"; }; run = "layout floating"; }
          # Finder preferences, info windows
          { "if" = { app-id = "com.apple.finder"; }; run = "layout floating"; }
          # UTM
          { "if" = { app-id = "com.utmapp.UTM"; }; run = "layout floating"; }
        ];
        
        persistent-workspaces = [
          "B"
          "C"
          "D"
          "I"
          "N"
          "S"
          "9"
        ];
        on-mode-changed = [ ];
        key-mapping.preset = "qwerty";
        gaps = {
          inner.horizontal = 2;
          inner.vertical = 2;
          outer.left = 0;
          outer.bottom = 0;
          outer.top = 0;
          outer.right = 0;
        };
        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";
          alt-shift-space = "layout floating tiling";
          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";
          alt-minus = "resize smart -50";
          alt-equal = "resize smart +50";
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";
          alt-a = "workspace A";
          alt-b = "workspace B";
          alt-c = "workspace C";
          alt-d = "workspace D";
          alt-e = "workspace E";
          alt-f = "workspace F";
          alt-g = "workspace G";
          alt-i = "workspace I";
          alt-m = "workspace M";
          alt-n = "workspace N";
          alt-o = "workspace O";
          alt-p = "workspace P";
          alt-q = "workspace Q";
          alt-r = "workspace R";
          alt-s = "workspace S";
          alt-t = "workspace T";
          alt-u = "workspace U";
          alt-v = "workspace V";
          alt-w = "workspace W";
          alt-x = "workspace X";
          alt-y = "workspace Y";
          alt-z = "workspace Z";
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";
          alt-shift-a = "move-node-to-workspace A";
          alt-shift-b = "move-node-to-workspace B";
          alt-shift-c = "move-node-to-workspace C";
          alt-shift-d = "move-node-to-workspace D";
          alt-shift-e = "move-node-to-workspace E";
          alt-shift-f = "move-node-to-workspace F";
          alt-shift-g = "move-node-to-workspace G";
          alt-shift-i = "move-node-to-workspace I";
          alt-shift-m = "move-node-to-workspace M";
          alt-shift-n = "move-node-to-workspace N";
          alt-shift-o = "move-node-to-workspace O";
          alt-shift-p = "move-node-to-workspace P";
          alt-shift-q = "move-node-to-workspace Q";
          alt-shift-r = "move-node-to-workspace R";
          alt-shift-s = "move-node-to-workspace S";
          alt-shift-t = "move-node-to-workspace T";
          alt-shift-u = "move-node-to-workspace U";
          alt-shift-v = "move-node-to-workspace V";
          alt-shift-w = "move-node-to-workspace W";
          alt-shift-x = "move-node-to-workspace X";
          alt-shift-y = "move-node-to-workspace Y";
          alt-shift-z = "move-node-to-workspace Z";
          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
          # Disable "hide application" & "hide others"
          cmd-h = [];
          cmd-alt-h = [];
          cmd-alt-right = "workspace --wrap-around next";
          cmd-alt-left = "workspace --wrap-around prev";
          alt-shift-semicolon = "mode service";
        };
        mode.service.binding = {
          esc = [ "reload-config" "mode main" ];
          r = [ "flatten-workspace-tree" "mode main" ];
          f = [ "layout floating tiling" "mode main" ];
          alt-shift-h = [ "join-with left" "mode main" ];
          alt-shift-j = [ "join-with down" "mode main" ];
          alt-shift-k = [ "join-with up" "mode main" ];
          alt-shift-l = [ "join-with right" "mode main" ];
        };
      };
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

    chawan = {
      enable = true;
      settings = {
        buffer = {
          images = true;
          autofocus = true;
        };
        external = {
          copy-cmd = "pbcopy";
          download-dir = "~/Downloads";
        };
        page = {
          f = "cmd.pager.toggleLinkHints";
          M-o = "pager.cursorNextLink()";
          M-i = "pager.cursorPrevLink()";
        };
      };
    };

    clock-rs = {
      enable = true;
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
      settings = {
        credential.helper = "${
            pkgs.git.override { withLibsecret = true; }
          }/bin/git-credential-libsecret";
        ghq = {
          root = "${config.home.homeDirectory}/Code";
          user = "palitronica";
        };
        init = {
          templateDir = "~/.git-template";
          defaultBranch = "main";
        };
        user = {
          name  = "Matt Thornback";
          email = "matt.thornback@palitronica.com";
        };
      };
      ignores = [
        "*.DS_Store"
        "*.swp"
      ];
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    intelli-shell = {
      enable = true;
      enableZshIntegration = true;
      shellHotkeys = {
        search_hotkey = "\\C-@";  # Ctrl+Space (ASCII NUL character)
        bookmark_hotkey = "\\C-b"; # Ctrl+b (default)
        variable_hotkey = "\\C-l"; # Ctrl+l (default)
        fix_hotkey = "\\C-x";      # Ctrl+x (default)
      };
      settings = {
        check_updates = true;
        inline = true;
        search = {
          delay = 250;
          mode = "auto";
          user_only = false;
          exec_on_alias_match = false;
        };
        logs = {
          enabled = false;
          filter = "info";
        };
        keybindings = {
          quit = "esc";
          update = ["ctrl-u" "ctrl-e" "F2"];
          delete = "ctrl-d";
          confirm = ["tab" "enter"];
          execute = ["ctrl-enter" "ctrl-r"];
          ai = ["ctrl-i" "ctrl-x"];
          search_mode = "ctrl-s";
          search_user_only = "ctrl-o";
          variable_next = "ctrl-tab";
          variable_prev = ["shift-tab" "shift-backtab"];
        };
        theme = {
          # Solarized Dark theme using hex codes
          # Base colors: base03=#002b36 base02=#073642 base01=#586e75 base00=#657b83
          # Content: base0=#839496 base1=#93a1a1 base2=#eee8d5 base3=#fdf6e3
          # Accent: yellow=#b58900 orange=#cb4b16 red=#dc322f magenta=#d33682
          #         violet=#6c71c4 blue=#268bd2 cyan=#2aa198 green=#859900
          primary = "#2aa198";           # Solarized cyan for primary text
          secondary = "#268bd2";         # Solarized blue for secondary
          accent = "#b58900";            # Solarized yellow for highlights
          comment = "italic #859900";    # Solarized green for comments
          error = "#dc322f";             # Solarized red for errors
          highlight = "#073642";         # Solarized base02 for highlight bg
          highlight_symbol = "» ";
          highlight_primary = "#93a1a1";    # Solarized base1 (bright content)
          highlight_secondary = "#2aa198";  # Solarized cyan for secondary highlight
          highlight_accent = "#b58900";     # Solarized yellow for accent
          highlight_comment = "italic #859900";  # Solarized green
        };
      };
    };

    kitty = {
      enable = true;
      shellIntegration = {
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
      extraConfig = ''
        # Create a new "manage windows" mode (mw)
        map --new-mode mw ctrl+a>m
        
        # Switch focus to the neighboring window in the indicated direction using arrow keys
        map --mode mw h neighboring_window left
        map --mode mw l neighboring_window right
        map --mode mw k neighboring_window up
        map --mode mw j neighboring_window down
        
        # Move the active window in the indicated direction
        map --mode mw shift+k move_window up
        map --mode mw shift+h move_window left
        map --mode mw shift+l move_window right
        map --mode mw shift+j move_window down
        
        # Resize the active window
        map --mode mw n resize_window narrower
        map --mode mw w resize_window wider
        map --mode mw t resize_window taller
        map --mode mw s resize_window shorter
        
        # Exit the manage window mode
        map --mode mw esc pop_keyboard_mode
      '';
      font = {
        name = "FiraCode Nerd Font";
        size = 11;
      };
      keybindings = {
        "kitty_mod+enter" = "new_window_with_cwd";
        "shift+cmd+v" = "paste_from_buffer a1";
        "ctrl+a>%" = "new_window_with_cwd";
        "ctrl+a>q" = "close_session";
        "ctrl+a>c" = "new_tab_with_cwd";
        "ctrl+alt+z" = "toggle_layout stack";
        "ctrl+alt+h" = "resize_window narrower";
        "ctrl+alt+j" = "resize_window shorter";
        "ctrl+alt+k" = "resize_window taller";
        "ctrl+alt+l" = "resize_window wider";
        # Pass Ctrl+Tab / Ctrl+Shift+Tab through to tmux
        "ctrl+tab" = "send_text all \\u001b[1;5I";
        "ctrl+shift+tab" = "send_text all \\u001b[1;6I";
        "ctrl+a>h" = "neighboring_window left";
        "ctrl+a>j" = "neighboring_window down";
        "ctrl+a>k" = "neighboring_window up";
        "ctrl+a>l" = "neighboring_window right";
        "ctrl+a>shift+h" = "move_window left";
        "ctrl+a>shift+j" = "move_window down";
        "ctrl+a>shift+k" = "move_window up";
        "ctrl+a>shift+l" = "move_window right";
        "ctrl+a>f5" = "save_as_session --use-foreground-process --match=session:. .";

        # Sessions
        "cmd+alt+1" = "goto_session ${config.xdg.configHome}/kitty/sessions/dashboard.kitty-session";
        "cmd+alt+2" = "goto_session ${config.xdg.configHome}/kitty/sessions/code.kitty-session";
        "cmd+alt+3" = "goto_session ${config.xdg.configHome}/kitty/sessions/kubernetes.kitty-session";

        # quick picker of all known goto_session entries
        "cmd+alt+p" = "goto_session --sort-by=alphabetical";

      };
      settings = {
        allow_remote_control = "yes";
        copy_on_select = "a1";
        cursor_trail = "3";
        cursor_trail_decay = "0.1 0.4";
        mouse_map = "right press ungrabbed paste_from_buffer a1";
        mouse_hide_wait	= "-3.0";

        enable_audio_bell = "no";
        visual_bell_duration = "0.1";
        bell_on_tab = "\"🔔 \"";
        tab_bar_style = "powerline";
        hide_window_decorations = "no";
        selection_foreground = "none";
        selection_background = "none";
        url_style = "dashed";
        macos_option_as_alt = "left";

        include = "~/.config/kitty/current-theme.conf";
      };
      # themeFile = "Solarized8_Dark";
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

    newsboat = {
      autoReload = true;
      browser = "qutebrowser";
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

    qutebrowser = {
      enable = true;
    };

    starship = {
      enable = true;
      # custom settings
      settings = {
        add_newline = true;
        format = "$all";
        line_break.disabled = true;
        right_format = "$time";

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

        time = {
          disabled = false;
          format = "[$time]($style)";
          time_format = "%H:%M:%S";
          style = "yellow";
        };
      };

    };

    tmux = {
      enable = true;
      focusEvents = true;
      keyMode = "vi";
      mouse = true;
      reverseSplit = true;
      terminal = "xterm-256color";
      extraConfig = ''
        # Enable richer key reports (needed for Ctrl+Tab passthrough from kitty)
        set -g xterm-keys on
        set -g base-index 1
        set -g renumber-windows on
        # Set terminal/OS window title to the tmux session name
        set -g set-titles on
        set -g set-titles-string '#S'
        set -g automatic-rename on
        set -g automatic-rename-format '#{?#{==:#{pane_current_command},ssh},#{pane_title},#{b:pane_current_path}}'
        set -s user-keys[0] "\e[1;5I"  # Ctrl+Tab
        set -s user-keys[1] "\e[1;6I"  # Ctrl+Shift+Tab

        # Ensure new splits start in the active pane's directory
        unbind %
        bind % split-window -h -c "#{pane_current_path}"
        unbind '"'
        bind '"' split-window -c "#{pane_current_path}"

        # Navigate windows with Ctrl+Tab / Ctrl+Shift+Tab (via user-keys)
        bind -n User0 next-window
        bind -n User1 previous-window
      '';
      plugins = with pkgs; [
        tmuxPlugins.tmux-fzf
        tmuxPlugins.tmux-powerline
        tmuxPlugins.tmux-floax
        tmuxPlugins.tmux-sessionx
        tmuxPlugins.sensible
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.tmux-colors-solarized
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-processes 'nvim ~/Users/matt/.nix-profile/bin/nvim->nvim ~/nix/store/.*/bin/nvim->nvim vim k9s wtfutil aerc newsboat'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes
          '';
        }
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

    yazi = {
      enable = true;
      extraPackages = with pkgs; [
        glow
      ];
      plugins = {
        # Use custom glow plugin with fixed deprecation warning
        glow = ./dotfiles/yazi/plugins/glow.yazi;
      };
      settings = {
        plugin = {
          prepend_previewers = [
            { name = "*.md"; run = "glow"; }
            { name = "*.markdown"; run = "glow"; }
          ];
        };
      };
      initLua = ''
        require("git"):setup()
      '';
    };

    zellij = {
      enable = true;
    };

    zsh = {
      enable = true;

      autosuggestion = {
        enable = true;
        highlight = "fg=#52676f,bg=dim";
      };

      completionInit = ''
        autoload -Uz compinit

        # Rebuild compinit cache only if the dump is older than a day
        if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
          compinit -C
        else
          compinit
        fi
      '';


      defaultKeymap = "viins";

      enableCompletion = true;

      sessionVariables = {
        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND = "bg=green,fg=black,bold";
        INTELLI_SKIP_ESC_BIND = "1";
        INTELLI_FIX_HOTKEY = "\\C-x\\C-f";
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
        zshConfigEarlyInit = lib.mkOrder 500 ''
          # Early
          # uncomment to enable profiling
          #zmodload zsh/zprof
          
          # Magic space for history expansion
          bindkey -M viins ' ' magic-space
        '';
        zshConfigBeforeCompInit = lib.mkOrder 550 "# BeforeCompInit";
        zshConfig = lib.mkOrder 1000 ''
          # Completion styling
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

          # Make "kubecolor" borrow the same completion logic as "kubectl"
          compdef kubecolor=kubectl

          # krew
          export PATH="''\${KREW_ROOT:-''\$HOME/.krew}/bin:$PATH"

        '';
        zshConfigLate = lib.mkOrder 1500 ''
          # Late

          ## edit current command in vi
          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey '^X^E' edit-command-line

          # uncomment to enable profiling
          #zprof
        '';
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

      siteFunctions = {
        # display Vault secrets
        showCreds = ''
          vault kv get -format=json -mount="''\${1}" "''\${2}" | \
          jq '.data.data | to_entries|map("\(.key)='"'"'\(.value|tostring)'"'"'")|.[]' -r
        '';

        # source Vault secrets into shell environment
        getCreds = ''
          eval $(vault kv get -format=json -mount="''\${1}" "''\${2}" | \
          jq '.data.data | to_entries|map("export \(.key)='"'"'\(.value|tostring)'"'"'")|.[]' -r)
        '';
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
