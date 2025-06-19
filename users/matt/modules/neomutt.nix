{ config, pkgs, ... }:

{
  programs.neomutt = {
    enable =true;

    sidebar = {
      enable = true;
    };

  };
}
