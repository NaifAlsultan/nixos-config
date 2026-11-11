{
  config,
  lib,
  pkgs,
  ...
}:

let
  hm = config.home-manager.users.naif;
  user = "opencode-remote";
  stateDir = "/var/lib/opencode-remote";
  workspace = "/home/naif/remote";
  shared = "/home/naif/shared";
  port = 4096;
  url = "http://127.0.0.1:${toString port}";
  # Readable by wheel, outside the sandbox.
  passwordFile = "/var/lib/opencode-remote-password/password";

  opencode = hm.programs.opencode.package;
  claude = hm.programs.claude-code.finalPackage;

  # Mounted read-only, so the server can't change its own config.
  configDir = pkgs.linkFarm "opencode-remote-config" (
    lib.mapAttrsToList (name: file: {
      name = lib.removePrefix "opencode/" name;
      path = file.source;
    }) (lib.filterAttrs (name: file: file.enable && lib.hasPrefix "opencode/" name) hm.xdg.configFile)
  );

  gitConfig = pkgs.writeText "opencode-remote-gitconfig" (
    lib.generators.toGitINI {
      inherit (hm.programs.git.settings) user;
      init.defaultBranch = "main";
      # Work trees in ~/remote belong to naif.
      safe.directory = "*";
    }
  );

  # Both users can write, including new files, whatever their umask.
  acl = lib.concatStringsSep "," [
    "u:${user}:rwX"
    "u:naif:rwX"
    "d:u::rwx"
    "d:u:${user}:rwx"
    "d:u:naif:rwx"
    "d:g::-"
    "d:o::-"
  ];

  startServer = pkgs.writeShellScript "start-opencode-remote" ''
    OPENCODE_PASSWORD="$(< "$CREDENTIALS_DIRECTORY/password")"
    export OPENCODE_PASSWORD
    exec ${opencode}/bin/opencode serve --hostname 127.0.0.1 --port ${toString port}
  '';

  opencodeRemote = pkgs.writeShellApplication {
    name = "opencode-remote";
    runtimeInputs = [
      opencode
      pkgs.curl
      pkgs.jq
      pkgs.qrencode
      config.services.tailscale.package
    ];
    text = ''
      url=${url}

      case "''${1-}" in
        pair)
          password=$(< ${passwordFile})
          host=$(tailscale status --json | jq -r '.Self.DNSName | rtrimstr(".")')
          code=$(curl -fsS -u "opencode:$password" -X POST "$url/api/pair" | jq -r .code)
          link="https://$host/auth/connect/$code"
          qrencode -t ansiutf8 "$link"
          echo "$link"
          echo "The link works once, within 5 minutes. The browser then stays signed in for 30 days."
          ;;
        claude-login)
          cd /
          exec sudo -u ${user} -H ${claude}/bin/claude auth login
          ;;
        help | -h | --help)
          echo "usage: opencode-remote [pair | claude-login | OPENCODE ARGS...]"
          echo
          echo "  pair          print a one-time sign-in link and QR code for a browser"
          echo "  claude-login  sign the server in to Claude"
          echo "  (otherwise)   run opencode against the sandboxed server, in ~/remote"
          echo "                unless already in ~/remote or ~/shared"
          ;;
        *)
          # The server takes the current directory as the location.
          case "$PWD" in
            ${workspace} | ${workspace}/* | ${shared} | ${shared}/*) ;;
            *) cd ${workspace} ;;
          esac
          OPENCODE_PASSWORD=$(< ${passwordFile}) exec opencode --server "$url" "$@"
          ;;
      esac
    '';
  };
in
{
  users.users.${user} = {
    isSystemUser = true;
    group = user;
    home = stateDir;
  };
  users.groups.${user} = { };

  environment.systemPackages = [ opencodeRemote ];

  services.tailscale.enable = true;

  systemd.tmpfiles.rules = [
    "d ${workspace} 0770 naif users - -"
    "A+ ${workspace} - - - - ${acl}"
    "A+ ${shared} - - - - ${acl}"
    # naif's git then refuses these repos, so their hooks and config can't run as naif.
    "z ${workspace}/*/.git - ${user} - -"
    # systemd creates it as root for the config bind mount.
    "d ${stateDir}/.config 0700 ${user} ${user} - -"
  ];

  systemd.services.opencode-remote-password = {
    description = "Generate the password of the remote OpenCode server";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Group = "wheel";
      StateDirectory = "opencode-remote-password";
      StateDirectoryMode = "0750";
      UMask = "0027";
    };
    script = ''
      if [[ ! -s ${passwordFile} ]]; then
        head -c 24 /dev/urandom | base64 | tr '+/' '-_' > ${passwordFile}.new
        mv ${passwordFile}.new ${passwordFile}
      fi
    '';
  };

  systemd.services.opencode-remote = {
    description = "OpenCode server for remote access, sandboxed to ~/remote and ~/shared";
    wantedBy = [ "multi-user.target" ];
    requires = [ "opencode-remote-password.service" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "opencode-remote-password.service"
    ];
    path = [
      opencode
      claude
      pkgs.git
      pkgs.typst
      "/run/current-system/sw"
    ]
    ++ hm.programs.opencode.extraPackages;
    environment = {
      HOME = stateDir;
      GIT_CONFIG_GLOBAL = gitConfig;
    };
    serviceConfig = {
      Type = "simple";
      User = user;
      Group = user;
      StateDirectory = user;
      StateDirectoryMode = "0700";
      WorkingDirectory = workspace;
      LoadCredential = "password:${passwordFile}";
      ExecStart = startServer;
      Restart = "always";
      RestartSec = 10;

      BindPaths = [
        workspace
        shared
      ];
      BindReadOnlyPaths = [ "${configDir}:${stateDir}/.config/opencode" ];

      # Internet only, plus Tailscale's MagicDNS resolver.
      IPAddressDeny = [
        "link-local"
        "multicast"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "100.64.0.0/10"
        "fc00::/7"
      ];
      IPAddressAllow = [
        "100.100.100.100"
        "fd7a:115c:a1e0::53"
      ];

      UMask = "0077";
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
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      SystemCallArchitectures = "native";
    };
  };

  systemd.services.opencode-remote-serve = {
    description = "Serve the remote OpenCode server over tailnet-only HTTPS";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "tailscaled.service"
      "opencode-remote.service"
    ];
    after = [
      "tailscaled.service"
      "opencode-remote.service"
    ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${config.services.tailscale.package}/bin/tailscale wait --timeout=30s";
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --yes --https=443 ${url}";
      Restart = "always";
      RestartSec = 30;
    };
  };
}
