{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = import ./theme.nix;

  # Adwaita's padlock, recoloured to the bar's text colour.
  padlock =
    name:
    pkgs.runCommand "${name}.svg" { } ''
      sed 's/#2e3436/#${theme.foreground}/' \
        ${pkgs.adwaita-icon-theme}/share/icons/Adwaita/symbolic/status/${name}.svg > $out
    '';
in
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
          # The icon names the padlocks below replace.
          TrayIconAppearance = "monochrome-light";
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

  # Replace KeePassXC's logo in the tray with a closed padlock when the database
  # is locked and an open one when it is unlocked.
  xdg.dataFile."icons/hicolor/scalable/apps/keepassxc-monochrome-light-locked.svg".source =
    padlock "changes-prevent-symbolic";
  xdg.dataFile."icons/hicolor/scalable/apps/keepassxc-monochrome-light.svg".source =
    padlock "changes-allow-symbolic";

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
