# NixOS Configuration

Unified NixOS and Home Manager configuration for multiple machines using Flakes.

## Project Structure

- `flake.nix`: Main entry point for the configuration.
- `configuration.nix`: Shared system configuration.
- `home.nix`: Shared Home Manager configuration.
- `hosts/`: Machine-specific hardware configurations.
  - `desktop/`: Hardware config for the desktop.
  - `laptop/`: Hardware config for the laptop.
- `dotfiles/`: Reusable Nix modules for specific programs (i3, helix, etc.).

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

## Remote access (desktop)

OpenCode runs as `naif` in `/home/naif/opencode-workspace`, with tailnet-only
HTTPS via Tailscale Serve. The SMB share is also accessible over Tailscale.

### Initial setup

1. Apply: `sudo nixos-rebuild switch --flake .#desktop`.
2. Enroll the desktop with `sudo tailscale up`; sign the iPhone app into the
   same tailnet.
3. Enable MagicDNS and HTTPS certificates in the [Tailscale DNS settings](https://console.tailscale.com/admin/dns).
   If Serve requests additional consent, check `journalctl -u opencode-serve`.
4. Open the HTTPS hostname under `Foreground.Web` in `tailscale serve status --json`
   in iPhone Safari. For files, connect in the iPhone Files app to
   `smb://<desktop-tailscale-ip>` (from `tailscale ip -4`) as Samba user `naif`.
