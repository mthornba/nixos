# nixos
NixOS Configs

## Install steps

- Perform initial install, creating my user
- clone this repo
- for a brand new system, copy `/etc/nixos/*.nix` to this repo
- rebuild config pointing to appropriate configuration.nix
  ```sh
  sudo nixos-rebuild switch -I nixos-config=./configuration.nix
  ```

### Upgrade to unstable

As root:
```sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
nixos-rebuild switch --upgrade
```

### Flakes

Load system config with a flake
```sh
sudo nixos-rebuild switch --flake .#
```
optionally, including the hostname:
```sh
sudo nixos-rebuild switch --flake .#neon
```

## X11 vs Wayland

By default, NixOS uses Wayland:
```sh
❯ echo $XDG_SESSION_TYPE
wayland
```

Add to `configuration.nix` to allow choosing between X11 and Wayland at login:
```nix
services.xserver.displayManager.defaultSession = "gnome-xorg";
```

## Home Manager

Add the master branch since we're following NixOS Unstable
```sh
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --update
```

Install Standalone
```sh
nix-shell '<home-manager>' -A install
```

Move Home Manager config into this repo
```sh
mv ~/.config/home-manager/home.nix users/matt
```

Apply Home Manager Config
```sh
home-manager switch -f ./users/matt/home.nix
```

### Allow Unfree

From [github.com/Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs/blob/972935c1b35d8b92476e26b0e63a044d191d49c3/minimal/home-manager/home.nix#L19):
Add to `home.nix`:
```nix
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
```

### Flakes

Install home-manager as a flake
```sh
nix run home-manager/master -- init
mv ~/.config/home-manager/* ./users/matt
home-manager switch --flake ./users/matt/flake.nix
```

If you don't need the initial config created:
```sh
nix run home-manager/master -- switch --flake ./users/matt
```
This will also install `home-manager` if `home.nix` includes:
```nix
# Let Home Manager install and manage itself.
programs.home-manager.enable = true;
```

#### Upgrading Packages

```sh
home-manager switch --flake ./users/matt --recreate-lock-file
```

## Connect Bluetooth Mouse & Keyboard

https://nixos.wiki/wiki/bluetooth

Neither would connect through GNOME settings. Used CLI:
```sh
$ bluetoothctl
[bluetooth] # power on
[bluetooth] # agent on
[bluetooth] # default-agent
[bluetooth] # scan on
[bluetooth] # pair [hex-address]
[bluetooth] # connect [hex-address]
[bluetooth] # trust [hex-address]
```


