{ config, lib, pkgs, ... }:

{
  programs.taskwarrior = {
    enable = false;
    colorTheme = "solarized-dark-256";
    package = pkgs.taskwarrior;
  };
}
