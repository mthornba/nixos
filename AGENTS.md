# Repository Guidelines

## Project Structure & Module Organization
- Root flake: `flake.nix` defines `nixosConfigurations.neon` (NixOS). Host configs live under `systems/<host>/` (e.g., `systems/neon/`).
- macOS (nix-darwin): separate flake in `systems/Matts-MacBook-Pro/flake.nix` and related `brew/` module.
- Shared NixOS modules: `modules/*.nix` (e.g., `octoprint.nix`, `syncthing.nix`).
- Home Manager: `users/matt/{flake.nix,home.nix,modules/}` for user-level configuration and dotfiles.
- Docs and notes: `docs/` (e.g., setup notes, TODOs).
- Build artifacts: `result` symlinks (gitignored), `*.log` files.

## Quick Commands
- **Full system rebuild**: `nix run .` (auto-detects macOS/NixOS, then runs home-manager)
- **Build only (no switch)**: Platform-specific commands below

## Build, Test, and Development Commands
- **Unified entry point**: `nix run .` auto-detects OS and rebuilds system + home-manager
- NixOS build: `sudo nixos-rebuild build --flake .#neon` (validate without switching).
- NixOS switch: `sudo nixos-rebuild switch --flake .#neon` (apply to host).
- macOS build/switch: `darwin-rebuild build|switch --flake ./systems/Matts-MacBook-Pro`.
- Home Manager: `home-manager switch --flake ./users/matt` or `--dry-run` to preview.
- Update inputs: run `nix flake update` in the target flake directory (root, `users/matt`, or `systems/Matts-MacBook-Pro`).

## Coding Style & Naming Conventions
- Nix files: 2-space indentation, trailing commas, concise comments for non-obvious options.
- Filenames: lower-kebab-case for modules (e.g., `syncthing.nix`), host folders match hostname (e.g., `neon`).
- Group related options and keep module scopes focused (device services, user apps, etc.).

## Testing Guidelines
- Prefer building before switching: `nixos-rebuild build` / `darwin-rebuild build`.
- For Home Manager, use `--dry-run` to confirm changes.
- Where applicable, `nix flake check` may run defined checks; otherwise, ensure evaluation succeeds by building targets for each platform.

## Commit & Pull Request Guidelines
- Conventional Commits: `feat(scope): …`, `fix(scope): …`, `chore: …` (matches current history).
- One logical change per commit; keep diffs minimal and scoped (e.g., a single module or host).
- PRs: include a short description, affected hosts/modules, any commands used to validate (e.g., `nixos-rebuild build --flake .#neon`), and update `docs/` when behavior changes.

## Security & Configuration Tips
- Do not commit secrets or device-specific tokens (e.g., Syncthing IDs). Use local overrides or environment-specific files kept untracked.
- Be mindful of private network addresses and hostnames in examples. Accept unfree licenses intentionally (see `allowUnfree` in flakes).

## Troubleshooting

### Common Issues

**"Not a trusted user" warning**
- Add user to `nix.settings.trusted-users` in darwin/nixos config
- Restart nix daemon: `sudo launchctl kickstart -k system/org.nixos.nix-daemon` (macOS) or `sudo systemctl restart nix-daemon` (NixOS)
- Log out and back in for changes to take full effect

**Mac App Store apps fail with "permission denied over SSH"**
- Error: "Apps could not be updated as darwin-rebuild requires Full Disk Access"
- Solution: Comment out `masApps` in `systems/Matts-MacBook-Pro/brew/default.nix` or grant Full Disk Access via System Settings > General > Sharing > Remote Login
- Apps can be installed manually via App Store UI

**Ctrl+Space doesn't work in terminal apps**
- macOS uses Ctrl+Space for input source switching by default
- Disable via: System Settings > Keyboard > Keyboard Shortcuts > Input Sources
- Uncheck "Select the previous input source" and "Select next source in Input menu"
- Log out and back in, or use alternative keybinding

**Build failures after flake updates**
- Check `nix flake check` for evaluation errors
- Review `flake.lock` changes with `git diff flake.lock`
- If needed, roll back with `nix flake lock --update-input <input> --override-input <input> <old-ref>`

**Home Manager changes not applying**
- Ensure `home-manager switch` was run after system rebuild
- Check `~/.config` for conflicting manually-created files
- Use `home-manager packages` to verify installed packages
