{ config, pkgs, ... }:

let
  claudeCode = config.home-manager.users.naif.programs.claude-code.finalPackage;
  stateDir = "/var/lib/claude-remote";
  startClaude = pkgs.writeShellScript "start-claude-remote-control" ''
    export PATH="/run/current-system/sw/bin:$PATH"
    exec ${claudeCode}/bin/claude remote-control --name "Desktop"
  '';
  # Runs claude as the service user, for one-time login and trust setup.
  claudeRemote = pkgs.writeShellScriptBin "claude-remote" ''
    exec sudo -u claude-remote -H ${pkgs.bash}/bin/bash -c 'cd ~/workspace && exec "$@"' bash ${claudeCode}/bin/claude "$@"
  '';
  # Mounted over /etc/claude-code inside the service only, so Claude cannot
  # loosen its own rules or add hooks and MCP servers.
  managedSettings = pkgs.writeTextDir "managed-settings.json" (builtins.toJSON {
    permissions = {
      allow = [ "Bash" "Read" "Edit" "WebFetch" "WebSearch" ];
      additionalDirectories = [ "/home/naif/shared" ];
    };
    allowManagedPermissionRulesOnly = true;
    allowManagedHooksOnly = true;
    allowManagedMcpServersOnly = true;
    allowedMcpServers = [ ];
  });
in
{
  users.users.claude-remote = {
    isSystemUser = true;
    group = "claude-remote";
    extraGroups = [ "shared" ];
    home = stateDir;
  };
  users.groups.claude-remote = { };

  environment.systemPackages = [ claudeRemote ];

  # Empty mount point; host-side Claude sessions see no managed settings.
  systemd.tmpfiles.rules = [
    "d /etc/claude-code 0755 root root - -"
  ];

  systemd.services.claude-remote-control = {
    description = "Claude Code Remote Control";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment.HOME = stateDir;
    serviceConfig = {
      Type = "simple";
      User = "claude-remote";
      Group = "claude-remote";
      StateDirectory = [ "claude-remote" "claude-remote/workspace" ];
      StateDirectoryMode = "0700";
      WorkingDirectory = "${stateDir}/workspace";
      ExecStart = startClaude;
      Restart = "always";
      RestartSec = 30;

      BindReadOnlyPaths = [ "${managedSettings}:/etc/claude-code" ];
      BindPaths = [ "/home/naif/shared" ];

      # Internet only: no LAN or tailnet, except Tailscale's MagicDNS resolver.
      IPAddressDeny = [
        "link-local"
        "multicast"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "100.64.0.0/10"
        "fc00::/7"
      ];
      IPAddressAllow = [ "100.100.100.100" "fd7a:115c:a1e0::53" ];

      UMask = "0007";
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      ProtectSystem = "strict";
      ProtectHome = "tmpfs";
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectProc = "invisible";
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      LockPersonality = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      SystemCallArchitectures = "native";
    };
  };
}
