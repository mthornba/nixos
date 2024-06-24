{ config, lib, pkgs, ... }:

{
  # home.packages = with pkgs; [
  #   rofi
  # ];

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "combi,window,drun,run,emoji,calc,keys";
      combi-modes = "window,drun";
      show-icons = true;
    };
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    terminal = "kitty";
    theme = "solarized_alternate";
  };
}
