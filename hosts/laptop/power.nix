{
  services.power-profiles-daemon.enable = true;
  systemd.services.power-profiles-daemon.wantedBy = [ "graphical.target" ];
}
