{ pkgs, ... }:

{
  # Backlight control for the brightness keys (laptop only; the desktop has no
  # backlight). The udev rule lets the video group write the brightness.
  environment.systemPackages = [ pkgs.brightnessctl ];
  services.udev.packages = [ pkgs.brightnessctl ];
  users.users.naif.extraGroups = [ "video" ];
}
