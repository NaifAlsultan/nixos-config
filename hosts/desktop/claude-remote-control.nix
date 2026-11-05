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
in
{
  users.users.claude-remote = {
    isSystemUser = true;
    group = "claude-remote";
    home = stateDir;
  };
  users.groups.claude-remote = { };

  environment.systemPackages = [ claudeRemote ];

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

      UMask = "0077";
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      ProtectSystem = "strict";
      ProtectHome = true;
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
