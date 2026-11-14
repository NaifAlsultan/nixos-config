# NixOS Configuration

Unified NixOS and Home Manager configuration for multiple machines using Flakes.

## Project Structure

- `flake.nix`: Main entry point for the configuration.
- `configuration.nix`: Shared system configuration.
- `home/`: Home Manager configuration.
  - `common.nix`: Settings for every machine, including non-NixOS ones.
  - `linux.nix`: The Linux desktop (Hyprland, Waybar, GTK, default apps).
- `hosts/`: Machine-specific configurations.
  - `desktop/`: Hardware config, Samba file sharing over LAN and Tailscale, and a sandboxed OpenCode server for the iPhone.
  - `laptop/`: Hardware config for the laptop.
- `system/`: System modules imported by `configuration.nix` (Chromium and its policies, [agent-browser](https://github.com/NaifAlsultan/agent-browser) for OpenCode, brightness control).
- `dotfiles/`: Home Manager modules, one per program (Hyprland, Waybar, Helix, etc.), imported by `home/common.nix` or `home/linux.nix`.
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

## Remote OpenCode (desktop)

A sandboxed OpenCode server for the iPhone, reachable only over Tailscale. It
can access `~/remote` and `~/shared`, nothing else in the home directory.

### Setup

1. Apply the configuration: `sudo nixos-rebuild switch --flake .#desktop`.
   Tailscale needs MagicDNS and HTTPS certificates enabled in the
   [admin console](https://login.tailscale.com/admin/dns).
2. Sign the server in to Claude:

   ```bash
   opencode-remote claude-login
   opencode-remote auth login claude-agent
   ```

3. With Tailscale on the iPhone, run `opencode-remote pair` and scan the QR
   code. Safari stays signed in for 30 days.

### Use

- On the desktop, use `opencode-remote` instead of `opencode` for `~/remote`;
  it shares sessions with the phone.
- Git in `~/remote` projects only works through OpenCode, by design.
- To add a project, move it into `~/remote` and run
  `sudo systemd-tmpfiles --create`.
