{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Settings are left unset here: a store-managed keepassxc.ini is read-only
  # and KeePassXC reports an error on every start (home-manager#8257).
  programs.keepassxc.enable = true;

  # So KeePassXC gets a writable copy, reset to these values on every switch.
  home.activation.keepassxcSettings =
    let
      settings = (pkgs.formats.ini { }).generate "keepassxc.ini" {
        General = {
          ConfigVersion = 2;
          # Keeps the previous version as Database.old.kdbx, to undo a bad merge.
          BackupBeforeSave = true;
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
