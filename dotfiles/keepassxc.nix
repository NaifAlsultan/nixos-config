{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Settings are left unset here: a store-managed keepassxc.ini is read-only
  # and KeePassXC reports an error on every start (home-manager#8257).
  programs.keepassxc = {
    enable = true;
    autostart = true;
  };
  # Required by `autostart`; KeePassXC is the only autostart entry.
  xdg.autostart.enable = true;

  # So KeePassXC gets a writable copy, reset to these values on every switch.
  home.activation.keepassxcSettings =
    let
      settings = (pkgs.formats.ini { }).generate "keepassxc.ini" {
        General = {
          ConfigVersion = 2;
          # Keeps the previous version as Database.old.kdbx, to undo a bad merge.
          BackupBeforeSave = true;
        };
        # Acts as the desktop keyring (Secret Service) for other apps.
        FdoSecrets.Enabled = true;
        # Keeps running in the Waybar tray instead of holding a workspace,
        # since closing it would also stop the keyring.
        GUI = {
          ShowTrayIcon = true;
          MinimizeToTray = true;
          MinimizeOnClose = true;
          MinimizeOnStartup = true;
        };
        PasswordGenerator = {
          Length = 20;
          SpecialChars = true;
        };
      };
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run install -Dm644 ${settings} "${config.xdg.configHome}/keepassxc/keepassxc.ini"
    '';

  # Qt looks for a tray only once at startup; if Waybar's isn't registered yet,
  # the icon never appears. Wait for it (up to 30s, then start anyway).
  xdg.configFile."systemd/user/app-org.keepassxc.KeePassXC@autostart.service.d/wait-for-tray.conf".text =
    let
      waitForTray = pkgs.writeShellScript "wait-for-tray" ''
        for _ in $(${pkgs.coreutils}/bin/seq 150); do
          ${pkgs.systemd}/bin/busctl --user status org.kde.StatusNotifierWatcher >/dev/null 2>&1 && exit 0
          ${pkgs.coreutils}/bin/sleep 0.2
        done
      '';
    in
    ''
      [Service]
      ExecStartPre=${waitForTray}
    '';
}
