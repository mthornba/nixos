# nixos
NixOS Configs

- Perform initial install, creating my user
- clone this repo
- for a brand new system, copy `/etc/nixos/*.nix` to this repo
- rebuild config pointing to appropriate configuration.nix
  ```sh
  sudo nixos-rebuild switch -I nixos-config=./configuration.nix
  ```

## Dell T3610


