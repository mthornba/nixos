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


