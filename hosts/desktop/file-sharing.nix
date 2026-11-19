{
  systemd.tmpfiles.rules = [
    # Group bits are the ACL mask for opencode-remote.
    "d /home/naif/shared 0770 naif users - -"
  ];

  services.samba = {
    enable = true;
    openFirewall = false;
    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        "server role" = "standalone server";
        "map to guest" = "never";
        "smb ports" = "445";
        "hosts allow" = "127.0.0.1 ::1 100.64.0.0/10 fd7a:115c:a1e0::/48";
        "hosts deny" = "ALL";
      };

      shared = {
        path = "/home/naif/shared";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "naif";
        "vfs objects" = "streams_xattr";
        # Group bits are the ACL mask for opencode-remote.
        "create mask" = "0660";
        "directory mask" = "0770";
      };
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 445 ];
}
