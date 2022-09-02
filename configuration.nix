# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [ "intel_idle.max_cstate=1" ]; # In case your laptop hangs randomly
  boot.loader = {
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      forcei686 = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      useOSProber = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.wireless.userControlled.enable = true;
  networking.wireless.environmentFile = "/home/matt/wireless.env";
  networking.wireless.networks = {
    "Horsefish" = {
      pskRaw = "@PSK_HORSEFISH@";
      authProtocols = [ "WPA-PSK" ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = true;
#  services.xserver.windowManager.dwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+dwm";

  services.xserver.windowManager.dwm = {
    enable = true;
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  hardware.enableAllFirmware = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    createHome = true;
    home = "/home/matt";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeo79G56E0Ogd4EIGEoqk4wO8tPSzu5J06PdjGODcgz4r4GU3ZYMQ1yN5JQzhxw7OqZOfBsAM9HCuRZdt1b78XvDZz1+n6xy90q95Uol2ouF7arxFb04qMgiIjGpoB8xWNjnivCPuKUkxjNkNxQ+nIYBio1LTezi/xr4TrZiykdVZKLzcUit24KqdNubNfsW5fcSOaCsvL2UzRcMsU7FhUPqyBnMsfw1mtN12u53IYAU7ikPy3CWHVegW+CYGC5EOUOjXNyQMulLlgw5QxBF0mzg4tZLt0rGFtsV97qs07BS5384h5saGjPHflGEIlxRacf0I3JTcKrV/HjjcP5Egx ansible-generated on matt-dell"
    ];
    packages = with pkgs; [
      barrier
      bat
      bitwarden-cli
      btop
      buku
      htop
      lsd
      qutebrowser
      (st.overrideAttrs (oldAttrs: rec {
        patches = [
          # Fetch them directly from `st.suckless.org`
          (fetchpatch {
            url = "https://st.suckless.org/patches/solarized/st-no_bold_colors-20170623-b331da5.diff";
            sha256 = "0iaq3wbazpcisys8px71sgy6k12zkhvqi4z47slivqfri48j3qbi";
          })
          (fetchpatch {
            url = "https://st.suckless.org/patches/solarized/st-solarized-both-20220617-baa9357.diff";
            sha256 = "13w101j9lz40xky3rba5clp2qkac18pgya567grm4ka2dnmahh5k";
          })
          # allow windows to fill available pixels
          (fetchpatch {
            url = "https://st.suckless.org/patches/anysize/st-anysize-20220718-baa9357.diff";
            sha256 = "1ym5d2f85l3avgwf9q93aymdg23aidprqwyh9s1fdpjvyh80rvvq";
          })
          # w3m image hack
          (fetchpatch {
            url = "https://st.suckless.org/patches/w3m/st-w3m-0.8.3.diff";
            sha256 = "1cwidwqyg6qv68x8bsnxns2h0gy9crd5hs2z99xcd5m0q3agpmlb";
          })
        ];
      }))
      syncthing
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    dmenu
    git
    git-crypt
    st
    surf
    tmux
    vim
    wget
  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  environment.shellAliases = {
    nix-search = "nix --extra-experimental-features 'nix-command flakes' search nixpkgs";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ls = "lsd";
      ll = "lsd -lA";
    };
  };

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
    ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

