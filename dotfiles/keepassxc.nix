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

  # So KeePassXC gets a writable copy, reset to these values on every switch.
  home.activation.keepassxcSettings =
    let
      settings = (pkgs.formats.ini { }).generate "keepassxc.ini" {
        General.ConfigVersion = 2;
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
}
