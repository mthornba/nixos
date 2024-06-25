{ config, lib, pkgs, ... }:

{

  home.packages = with pkgs; [
    libsecret # installs secret-tool
    pinentry-curses
  ];

  programs = {

    gpg = {
      enable = true;
    };

    password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "/home/matt/.local/share/password-store";
      };
    };

  };

  services = {

    gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      pinentryPackage = pkgs.pinentry-curses;
      verbose = true;
    };

  };

}
