{ config, lib, pkgs, ... }:

let
  defaultImports = [
    ./modules/lsq.nix
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

  # Manage pipx packages declaratively
  home.activation.installPipxPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    PATH="${config.home.path}/bin:$PATH"
    
    # List of pipx packages to install
    PIPX_PACKAGES=(
      "twg"
    )
    
    # Install or upgrade packages
    for pkg in "''${PIPX_PACKAGES[@]}"; do
      if ${pkgs.pipx}/bin/pipx list 2>/dev/null | grep -q "package $pkg"; then
        # Package exists, upgrade it
        $DRY_RUN_CMD ${pkgs.pipx}/bin/pipx upgrade "$pkg" || true
      else
        # Package doesn't exist, install it
        $DRY_RUN_CMD ${pkgs.pipx}/bin/pipx install "$pkg"
      fi
    done
    
    # Optional: Remove packages not in the list (similar to brew cleanup)
    # Uncomment if you want declarative cleanup:
    # ${pkgs.pipx}/bin/pipx list --short 2>/dev/null | while read -r installed_pkg; do
    #   if [[ ! " ''${PIPX_PACKAGES[@]} " =~ " ''${installed_pkg} " ]]; then
    #     $DRY_RUN_CMD ${pkgs.pipx}/bin/pipx uninstall "$installed_pkg"
    #   fi
    # done
  '';

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # cli apps
    aichat
    bat
    bitwarden-cli
    browsh
    btop
    buku
    carl
    chatgpt-cli
    colordiff
    copilot-language-server
    curlie
    ddgr
    delta
    docker-client  # Docker CLI for use with OrbStack
    doggo
    dos2unix
    fd
    file
    gfold
    git-filter-repo
    gita
    frogmouth
    ghq
    github-copilot-cli
    gitnr
    glow
    gnupg
    gum
    htop
    ipcalc
    jless
    jq
    jqp
    keychain
    lazygit
    lazyssh
    lsd
    nb
    ncdu
    nerd-fonts.fira-code
    nmap
    pipx
    procs
    pstree
    pv
    ripgrep
    serpl
    signal-cli
    silver-searcher
    so
    spec-kit
    sshs
    termscp
    tldr
    tmuxp
    unrar
    unzip
    viddy
    w3m
    wtfutil
    zip
    # graphical apps
    slack
    vscode # unfree
  ] ++ [
    # Custom scripts
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
    ".local/bin/ranger".text = ''
        #!/usr/bin/env bash
        exec yazi "$@"
      '';
    ".local/bin/ranger".executable = true;
    ".config/kitty/sessions".source = dotfiles/kitty/sessions;
    ".config/newsboat/bookmark.sh".source = scripts/newsboat/bookmark.sh;
    ".config/wtf/config.yml".source = dotfiles/wtf/config.yml;
    ".config/zellij/config.kdl".source = dotfiles/zellij/config.kdl;
    ".config/tmux-powerline/config.sh".source = dotfiles/tmux-powerline/config.sh;
    ".config/tmux-powerline/themes/nixos-minimal.sh".source = dotfiles/tmux-powerline/themes/nixos-minimal.sh;
    ".tmuxp/code.yml".source = dotfiles/tmuxp/code.yml;
    ".tmuxp/dashboard.yml".source = dotfiles/tmuxp/dashboard.yml;
    ".tmuxp/kubernetes.yml".source = dotfiles/tmuxp/kubernetes.yml;
    ".local/bin/vault-token-renewer".source = scripts/vault-token-renewer.sh;
    ".config/finicky/finicky.js".text = ''
      export default {
      defaultBrowser: "qutebrowser",
      options: {
        checkForUpdates: false,
        logRequests: false,
        hideIcon: false,
      },

      // Browser selection rules
      handlers: [
        {
          // Open links from these apps in Browserino for choice
          match: (options) => {
            const opener = options.opener;
            if (opener && opener.name) {
              return ["Slack", "Mail", "Microsoft Outlook"].includes(opener.name);
            }
            return false;
          },
          browser: "Browserino"
        }
      ]
    };
    '';

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

  home.sessionPath = [
    "${config.home.profileDirectory}/bin"  # Nix packages (vim alias, etc)
    "/opt/homebrew/bin"                     # Apple Silicon Homebrew
    "/usr/local/bin"                        # Intel Homebrew
    "$HOME/.local/bin"                      # pipx and custom scripts
  ];

  launchd.agents.vault-token-renewer = {
    enable = true;
    config = {
      ProgramArguments = [ "${config.home.homeDirectory}/.local/bin/vault-token-renewer" ];
      KeepAlive = false;
      RunAtLoad = false;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/vault-token-renewer.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/vault-token-renewer.error.log";
      EnvironmentVariables = {
        PATH = "${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        VAULT_ADDR = "https://vault.internal.palitronica.com";
      };
    };
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
          # Azure VPN Client
          { "if" = { app-id = "com.microsoft.AzureVpnMac"; }; run = "layout floating"; }
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
          alt-f = "fullscreen";
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

    diff-so-fancy = {
      enable = true;
      enableGitIntegration = false;
      pagerOpts = [
        "--tabs=4"
        "-RFXS"
      ];
      settings = {
        semIntegration = true;
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
      tmux.enableShellIntegration = true;
      enableZshIntegration = false;
    };

    gh = {
      enable = true;
    };

    ghostty = {
      enable = true;
      enableZshIntegration = true;
      package = pkgs.ghostty-bin;
      settings = {
        adjust-cell-width = "5%";
        background-blur-radius = 30;
        background-opacity = 0.90;
        bell-features = "no-attention,border,title";
        cursor-text = "cell-background";
        font-family = "FiraCode Nerd Font";
        font-size = 12;
        keybind= [
          "global:ctrl+grave_accent=toggle_quick_terminal"
          "global:option+space=toggle_quick_terminal"
          "ctrl+tab=csi:1;5I"
          "ctrl+shift+tab=csi:1;6I"
        ];
        macos-icon = "custom-style";
        macos-icon-frame = "beige";
        macos-icon-ghost-color = "#33FF00";
        macos-icon-screen-color = "#33FF00,#28CC28,#282828,#000000";
        macos-titlebar-style = "hidden";
        mouse-hide-while-typing = "true";
        mouse-scroll-multiplier = 0.5;
        quick-terminal-position = "center";
        quick-terminal-screen = "mouse";
        quick-terminal-size = "1450px,75%"; # 75% of 1964
        shell-integration-features = "no-cursor";
        theme = "Solarized Dark Higher Contrast";
        window-padding-x = 4;
        window-padding-y = 4;
        # load this config file if it exists
        config-file = "?config.manual";
      };
    };

    git = {
      enable = true;
      settings = {
        alias = {
          dsf = "diff --color";
        };
        pager = {
          dsf = "diff-so-fancy | less --tabs=4 -RFXS";
        };
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

    nix-search-tv = {
      enable = true;
      enableTelevisionIntegration = true;
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
      keyBindings = {
        normal = {
          ",d" = "config-cycle colors.webpage.darkmode.enabled true false";
        };
      };
      settings = {
        colors.webpage.darkmode.enabled = true;
      };
    };

    sesh = {
      enable = true;
      enableTmuxIntegration = true;
      icons = true;
    };

    starship = {
      enable = true;
      # custom settings
      settings = {
        add_newline = true;
        format = "$os$all$fill$time$line_break$character";

        os = {
          disabled = false;
          style = "white";
          symbols = {
            Macos = "󰀵 ";
            Linux = "󰌽 ";
          };
        };

        aws.disabled = true;
        gcloud.disabled = true;

        kubernetes = {
          symbol = "󱃾 ";
          contexts = [
            {
              context_pattern = "^(none|disabled|safe)$";
              symbol = "";
              context_alias = "";
              style = "dimmed";
            }
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
          format = "[$symbol$context( \\($namespace\\)) ]($style)";
          detect_extensions = [];
          detect_files = [];
          detect_folders = [];
        };

        lua = {
          symbol = "󰢱 ";
        };

        nix_shell = {
          symbol = "󱄅 ";
        };

        git_branch = {
          symbol = "󰘬 ";
        };

        fill = {
          symbol = "─";
          style = "bold dimmed";
        };

        time = {
          disabled = false;
          format = "[$time]($style)";
          time_format = " %H:%M:%S";
          style = "yellow";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
      };

    };

    television = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        ui = {
          show_preview_panel = false;
          status_bar = {
            hidden = false;
          };
          theme = "solarized-dark";
          use_nerd_font_icons = true;
          ui_scale = 100;
        };
        shell_integration ={
          keybindings = {
            smart_autocomplete = "ctrl-t";
            command_history = "ctrl-r";
          };
        };
      };
    };

    tmux = {
      enable = true;
      focusEvents = true;
      keyMode = "vi";
      mouse = true;
      reverseSplit = true;
      terminal = "tmux-256color";
      extraConfig = ''
        # Update PATH from shell environment to prevent stale paths in splits
        set-option -g update-environment "PATH"
        
        # Enable true color support
        set -ga terminal-overrides ",xterm-256color:Tc"
        set -ga terminal-overrides ",xterm-kitty:Tc"
        set -ga terminal-overrides ",xterm-ghostty:Tc"


        # Enable richer key reports (needed for Ctrl+Tab passthrough from kitty/ghostty)
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

        # Ensure new windows start in home directory
        unbind c
        bind c new-window -c ~

        # Navigate windows with Ctrl+Tab / Ctrl+Shift+Tab (via user-keys)
        bind -n User0 next-window
        bind -n User1 previous-window

        # Pass-through bindings: prefix + Ctrl+vim-keys sends the keystroke to TUI apps
        bind C-h send-keys C-h
        bind C-j send-keys C-j
        bind C-k send-keys C-k
        bind C-l send-keys C-l
        bind-key "K" run-shell "tmux display-popup -E -w 50 -h 20 'sesh connect \"$(sesh list -it | gum filter --limit 1 --placeholder \"Pick a sesh\" --prompt=\"⚡\")\"'"
      '';
      plugins = with pkgs; [
        tmuxPlugins.fzf-tmux-url
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
      shellWrapperName = "y";  # Use new default wrapper name
    };

    zellij = {
      enable = false;
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
          "^[[B"  # Standard down arrow
          "^[OB"  # Application mode down arrow
          "^N"    # Ctrl-N (works in both modes)
        ];
        searchUpKey = [
          "^[[A"  # Standard up arrow
          "^[OA"  # Application mode up arrow
          "^P"    # Ctrl-P (works in both modes)
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
          # Completion styling with fuzzy substring matching
          zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

          # Make "kubecolor" borrow the same completion logic as "kubectl"
          compdef kubecolor=kubectl

          # sesh completion
          source <(sesh completion zsh)

          # krew
          export PATH="''\${KREW_ROOT:-''\$HOME/.krew}/bin:$PATH"

        '';
        zshConfigLate = lib.mkOrder 1500 ''
          # Late

          ## edit current command in vi
          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey '^X^E' edit-command-line

          # Ensure history-substring-search works in vi mode
          bindkey -M vicmd 'k' history-substring-search-up
          bindkey -M vicmd 'j' history-substring-search-down
          bindkey -M viins '^[[A' history-substring-search-up
          bindkey -M viins '^[[B' history-substring-search-down

          # Television file picker widget
          function _television-file-picker() {
            local selected=$(tv files)
            if [[ -n "$selected" ]]; then
              LBUFFER="$LBUFFER$selected"
              zle reset-prompt
            fi
          }
          zle -N _television-file-picker
          bindkey '^T' _television-file-picker

          # Show timestamp when command is executed
          preexec() {
            echo -ne "\r\033[2K\033[2m 󰔛 [ $(date '+%H:%M:%S') ]\n\033[0m"
          }

          # splashboard — render on new shell and on directory change
          eval "$(splashboard init zsh)"

          # uncomment to enable profiling
          #zprof
        '';
      in
        lib.mkMerge [ zshConfigEarlyInit zshConfigBeforeCompInit zshConfig zshConfigLate ];

      shellAliases = {
        # buku
        b = "buku --np";
        # ghq
        cdr = "cd $(ghq list -p | fzf)";
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
        csdiff = ''
          csdiff -w $(stty size | awk '{print $NF}') $@ | colordiff
        '';
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

        # Clone with ghq and cd into the cloned directory
        gclone = ''
          ghq get -p "$@" && cd "$(ghq list -p -e "$(echo "$1" | sed -E 's#^(https://|ssh://git@)##; s#\.git$##')")"
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
            sha256 = "QkiUAvefSD4RauHP9j+TJaEgL4aBhDIe1UcXKHG9ATQ=";
          };
        }
        {
          name = "ohmyzsh-git";
          file = "plugins/git/git.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "ohmyzsh";
            repo = "ohmyzsh";
            rev = "master";
            sha256 = "QkiUAvefSD4RauHP9j+TJaEgL4aBhDIe1UcXKHG9ATQ=";
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
