{ pkgs, ... }:

{
  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    dotIcons.enable = false;
    gtk.enable = true;
  };

  gtk.enable = true;
  # Also sets the portal's color-scheme, which Chromium and LibreWolf follow.
  gtk.colorScheme = "dark";
}
