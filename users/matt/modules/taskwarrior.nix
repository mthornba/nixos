{ config, lib, pkgs, ... }:

{
  programs.taskwarrior = {
    enable = true;
    colorTheme = "solarized-dark-256";
    package = pkgs.taskwarrior;
  };
}
