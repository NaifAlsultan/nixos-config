{
  systemd.tmpfiles.rules = [
    "d /home/naif/shared 0700 naif users - -"
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
        "interfaces" = "lo wlp5s0";
        "bind interfaces only" = "yes";
        "smb ports" = "445";
        "hosts allow" = "127.0.0.1 192.168.0.0/24";
        "hosts deny" = "0.0.0.0/0";
      };

      shared = {
        path = "/home/naif/shared";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "naif";
        "create mask" = "0600";
        "directory mask" = "0700";
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

  networking.firewall.interfaces.wlp5s0 = {
    allowedTCPPorts = [ 445 ];
    allowedUDPPorts = [ 5353 ];
  };
}
