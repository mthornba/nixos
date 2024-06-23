{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in {

  home.packages = with pkgs; [
    picom
  ];

  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = mod;

      bars = [
        # {
        #   position = "top";
        #   statusCommand = "${pkgs.i3status}/bin/i3status";
        # }
      ];

      colors = {
        focused = {
          background = "#285577";
          border = "#728905";
          childBorder = "#728905";
          indicator = "#2e9ef4";
          text = "#ffffff";
        };
      };

      floating = {
        criteria = [
          {
            class = ".blueman-manager-wrapped";
          }
          {
            class = "Plexamp";
          }
        ];
        titlebar = false;
      };

      gaps = {
        inner = 10;
        outer = 0;
        smartBorders = "on";
        smartGaps = true;
      };

      keybindings = lib.mkOptionDefault {
        # Logout
        "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'xfce4-session-logout'";

        # Focus
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # Move
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # Move workspaces
        "${mod}+Shift+greater" = "move workspace to output left";
        "${mod}+Shift+less" = "move workspace to output right";

        # Splits
        "${mod}+semicolon" = "split h";
        "${mod}+v" = "split v";

        # Volume Keys
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 0.1+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 0.1-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_SINK@ toggle";

        # Rofi
        "${mod}+Tab" = "exec rofi -show";

      };

      startup = [
        { command = "picom"; always = false; notification = false; }
      ];

      terminal = "kitty";

      window = {
        border = 2;
        titlebar = false;
        commands = [
          {
            command = "border pixel 0";
            criteria = {
              class = "Plexamp";
            };
          }
        ];
      };

      workspaceAutoBackAndForth = true;

    };

    extraConfig = ''
      # force borders on all apps
      for_window [class=^(?i)(?!Plexamp)(?!.blueman-manager-wrapped).*] border normal 1
    '';

  };

}
