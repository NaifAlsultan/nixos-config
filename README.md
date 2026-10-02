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

The desktop runs Tailscale and a password-protected OpenCode web server on
`127.0.0.1:4096`, starting in `/home/naif/opencode-workspace`.
Tailscale Serve provides private HTTPS access to that server; the existing
`shared` SMB share is also available over Tailscale. Neither service needs
router port forwarding.

### Initial setup

1. Create the OpenCode password on the desktop **before** applying the configuration.
   This password is kept outside the Git repository and is requested by Safari
   when opening OpenCode (username: `opencode`):

   ```bash
   sudo install -d -m 0700 /etc/opencode
   sudo sh -c 'umask 077; systemd-ask-password "OpenCode server password:" > /etc/opencode/server-password'
   ```

2. Apply the desktop configuration:

   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   ```

3. Enroll the desktop and iPhone in the **same tailnet**. On the desktop:

   ```bash
   sudo tailscale up
   ```

   Follow the login link. Install the Tailscale iPhone app, sign in, and connect.
   For uninterrupted access, consider disabling key expiry for the desktop in
   the Tailscale admin console.

4. In the Tailscale admin console, enable **MagicDNS** and **HTTPS Certificates**
   under [DNS](https://console.tailscale.com/admin/dns). This one-time tailnet
   consent is required for Serve to obtain HTTPS certificates.
   NixOS manages the private Serve mapping; it starts automatically once the
   desktop is enrolled and HTTPS is enabled. If the service requests separate
   Serve consent, follow the URL in `journalctl -u opencode-serve.service`.
   Get the OpenCode URL with:

   ```bash
   tailscale serve status --json
   ```

   Look for the HTTPS hostname in the `Foreground.Web` section and open it in
   iPhone Safari. The plain `tailscale serve status` command may say "No serve
   config" for this systemd-managed foreground process. NixOS runs **Serve**,
   not Funnel: Funnel would make the site public.

5. In the iPhone **Files** app, go to **Browse → ⋯ → Connect to Server** and
   enter `smb://<desktop-tailscale-ip>` (get the IP with `tailscale ip -4` on
   the desktop). Log in as the existing Samba user `naif` with its **Samba
   password**, then open the `shared` share. SMB discovery via Avahi works on
   the home Wi-Fi only; remote access uses the Tailscale IP directly. The
   firewall limits SMB to the home Wi-Fi and Tailscale interfaces, including
   when Tailscale connects after Samba starts.

Test both links from the iPhone on cellular with Tailscale connected. Check
`systemctl status opencode-web.service opencode-serve.service` and
`tailscale serve status --json` on the desktop if the browser page is unavailable.
The OpenCode service runs as
`naif` even when nobody is logged in, and reads its password from
`/etc/opencode/server-password` via a systemd credential. To change the
password, replace that root-only file and restart `opencode-web.service`.
The dedicated working directory keeps new files out of the top level of the
home directory, but it does not limit disk usage: both paths use the same
filesystem.
