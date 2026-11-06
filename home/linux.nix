{ pkgs, ... }:

{
  imports = [
    ../dotfiles/default-apps.nix
    ../dotfiles/fuzzel.nix
    ../dotfiles/gtk.nix
    ../dotfiles/hypridle.nix
    ../dotfiles/hyprland.nix
    ../dotfiles/hyprlock.nix
    ../dotfiles/hyprsunset.nix
    ../dotfiles/keepassxc.nix
    ../dotfiles/librewolf.nix
    ../dotfiles/mako.nix
    ../dotfiles/waybar.nix
    ../dotfiles/zathura.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    libreoffice
  ];

  services.hyprpolkitagent.enable = true;
}
