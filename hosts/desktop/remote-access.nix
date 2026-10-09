{ config, pkgs, ... }:

let
  claudeCode = config.home-manager.users.naif.programs.claude-code.finalPackage;
  startClaude = pkgs.writeShellScript "start-claude-remote-control" ''
    export PATH="/etc/profiles/per-user/naif/bin:/run/current-system/sw/bin:$PATH"
    exec ${claudeCode}/bin/claude remote-control --name "Desktop"
  '';
in
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/naif/claude-workspace 0700 naif users - -"
  ];

  systemd.services.claude-remote-control = {
    description = "Claude Code Remote Control";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment.HOME = "/home/naif";
    serviceConfig = {
      Type = "simple";
      User = "naif";
      WorkingDirectory = "/home/naif/claude-workspace";
      ExecStart = startClaude;
      Restart = "always";
      RestartSec = 30;
    };
  };
}
