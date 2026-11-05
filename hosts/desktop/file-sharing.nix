{
  # Members can read and write ~/shared; claude-remote is one of them.
  users.groups.shared = { };
  users.users.naif.extraGroups = [ "shared" ];

  systemd.tmpfiles.rules = [
    "d /home/naif/shared 2770 naif shared - -"
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
        "hosts allow" = "127.0.0.1 192.168.0.0/24 100.64.0.0/10";
        "hosts deny" = "0.0.0.0/0";
      };

      shared = {
        path = "/home/naif/shared";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "naif";
        "vfs objects" = "streams_xattr";
        "force group" = "shared";
        "create mask" = "0660";
        "directory mask" = "2770";
      };
    };
  };

  services.avahi = {
    enable = true;
    openFirewall = false;
    allowInterfaces = [ "wlp5s0" ];
    ipv6 = false;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.interfaces.wlp5s0 = {
    allowedTCPPorts = [ 445 ];
    allowedUDPPorts = [ 5353 ];
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 445 ];
}
