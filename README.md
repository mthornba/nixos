# nixos
NixOS Configs

- Perform initial install, creating my user
- clone this repo
- for a brand new system, copy `/etc/nixos/*.nix` to this repo
- rebuild config pointing to appropriate configuration.nix
  ```sh
  sudo nixos-rebuild switch -I nixos-config=./configuration.nix
  ```

## Upgrade to unstable

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


