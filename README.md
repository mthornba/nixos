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

## Home Manager

```sh
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --update
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


## Dell T3610


