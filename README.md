# NixOS Configuration

Unified NixOS and Home Manager configuration for multiple machines using Flakes.

## Project Structure

- `flake.nix`: Main entry point for the configuration.
- `configuration.nix`: Shared system configuration.
- `home.nix`: Shared Home Manager configuration.
- `hosts/`: Machine-specific configurations.
  - `desktop/`: Hardware config, Samba file sharing over LAN and Tailscale, and the Claude Code remote control service.
  - `laptop/`: Hardware config for the laptop.
- `system/`: System modules imported by `configuration.nix` (Chromium policies).
- `dotfiles/`: Home Manager modules, one per program (Hyprland, Waybar, Helix, etc.), imported by `home.nix`.
  - `theme.nix`: The shared colour palette every themed program reads.

## Usage

### Apply Configuration

To apply the configuration for a specific machine, run the following command from this directory:

**For Desktop:**
```bash
sudo nixos-rebuild switch --flake .#desktop
```

**For Laptop:**
```bash
sudo nixos-rebuild switch --flake .#laptop
```

### Update Dependencies

To update the flake inputs (like nixpkgs):
```bash
nix flake update
```

### Check for Errors

To verify the flake configuration without applying it:
```bash
nix flake check
```

### Claude Code prerequisites (desktop)

Remote Control runs as the sandboxed `claude-remote` system user, which can only see
`/var/lib/claude-remote/workspace`. It has its own Claude login, separate from `naif`'s.
After rebuilding, set it up once with an eligible Claude subscription:

```bash
sudo systemctl stop claude-remote-control
claude-remote auth login
claude-remote
```

Accept workspace trust, then exit with `/exit`. Run
`claude-remote remote-control --name "Desktop"`, accept Remote Control, press Ctrl+C, then run
`sudo systemctl start claude-remote-control`.
