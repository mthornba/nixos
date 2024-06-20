{ config, lib, pkgs, ... }:

{
  # home.packages = with pkgs; [
  #   rofi
  # ];

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "window,drun,run,emoji,calc,keys";
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
