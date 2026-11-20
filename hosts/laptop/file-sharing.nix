{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/home/naif/shared" = {
    device = "//desktop/shared";
    fsType = "cifs";
    options = [
      "credentials=/etc/smb-credentials"
      "uid=naif"
      "gid=users"
      "file_mode=0660"
      "dir_mode=0770"
      "_netdev"
      "noauto"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=10"
      "x-systemd.after=tailscaled.service"
    ];
  };
}
