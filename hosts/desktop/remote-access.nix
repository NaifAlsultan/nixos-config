{ pkgs, inputs, ... }:

let
  opencode = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode;
  startOpencode = pkgs.writeShellScript "start-opencode-web" ''
    export PATH="/etc/profiles/per-user/naif/bin:/run/current-system/sw/bin:$PATH"
    export OPENCODE_SERVER_PASSWORD="$(< "$CREDENTIALS_DIRECTORY/opencode-password")"
    if [[ -z "$OPENCODE_SERVER_PASSWORD" ]]; then
      echo "OpenCode server password must not be empty" >&2
      exit 1
    fi
    exec ${opencode}/bin/opencode web --hostname 127.0.0.1 --port 4096
  '';
in
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/naif/opencode-workspace 0700 naif users - -"
  ];

  systemd.services.opencode-web = {
    description = "OpenCode web interface (Tailscale Serve backend)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "naif";
      WorkingDirectory = "/home/naif/opencode-workspace";
      LoadCredential = "opencode-password:/etc/opencode/server-password";
      ExecStart = startOpencode;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.services.opencode-serve = {
    description = "Serve OpenCode over tailnet-only HTTPS";
    wantedBy = [ "multi-user.target" ];
    wants = [ "tailscaled.service" "opencode-web.service" ];
    after = [ "tailscaled.service" "opencode-web.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.tailscale}/bin/tailscale wait --timeout=30s";
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --yes --https=443 http://127.0.0.1:4096";
      Restart = "always";
      RestartSec = 30;
    };
  };
}
