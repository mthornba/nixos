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
        {
          position = "top";
          statusCommand = "${pkgs.i3status}/bin/i3status";
        }
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
        "${mod}+j" = "focus left";
        "${mod}+k" = "focus down";
        "${mod}+l" = "focus up";
        "${mod}+semicolon" = "focus right";

        # Move
        "${mod}+Shift+j" = "move left";
        "${mod}+Shift+k" = "move down";
        "${mod}+Shift+l" = "move up";
        "${mod}+Shift+semicolon" = "move right";

        # Volume Keys
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 0.1+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 0.1-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_SINK@ toggle";
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
