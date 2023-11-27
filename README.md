# NixOS Configs

- Perform intiial install from USB, creating my user
- reboot

## Upgrade to unstable channel

Is this necessary if I'm going to use flakes?
```sh
sudo -i
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
nixos-rebuild switch --upgrade
```

## Flakes

1. Install `git` in a `nix shell`
```sh
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git
```

2. Clone this repo
```sh
git clone https://github.com/mthornba/nixos.git ~/.nixos
```

3. Load system config with a flake
```sh
sudo nixos-rebuild switch --flake .#
```
optionally, including the hostname:
```sh
sudo nixos-rebuild switch --flake .#neon
```

In some cases, such as the initial install, need to specify the hostname.

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
