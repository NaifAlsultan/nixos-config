{ pkgs, ... }:

let
  theme = import ../dotfiles/theme.nix;
in
{
  imports = [
    ../dotfiles/fuzzel.nix
    ../dotfiles/hyprland.nix
    ../dotfiles/hyprlock.nix
    ../dotfiles/keepassxc.nix
    ../dotfiles/waybar.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.nushell.shellAliases.c = "wl-copy";

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

  services.hypridle = {
    enable = true;
    settings.listener = [
      {
        timeout = 600;
        on-timeout = ''hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' '';
        on-resume = ''hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' '';
      }
    ];
  };

  services.hyprpolkitagent.enable = true;

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      background-color = "#${theme.background}";
      border-color = "#${theme.accent}";
      border-radius = 0;
      border-size = 1;
      default-timeout = 5000;
      font = "monospace 10";
      text-color = "#${theme.foreground}";
    };
  };

  services.hyprsunset = {
    enable = true;
    settings.profile = [
      {
        time = "06:00";
        temperature = 5500;
      }
      {
        time = "18:00";
        temperature = 3700;
      }
    ];
  };

  xdg.autostart.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      # Claude Code writes this handler's .desktop file itself at runtime.
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    };
  };
  # Replaces the mimeapps.list that apps had written by hand.
  xdg.configFile."mimeapps.list".force = true;
}
