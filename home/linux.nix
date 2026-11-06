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
    ../dotfiles/zathura.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    libreoffice
  ];

  # Uses LibreWolf's own defaults (uBlock Origin, DuckDuckGo, privacy settings)
  # and adds only what differs. No `profiles`, so the existing profile is kept.
  programs.librewolf = {
    enable = true;
    policies = {
      ExtensionSettings."addon@darkreader.org" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        installation_mode = "normal_installed";
      };
      # Open PDF links in the built-in viewer instead of downloading them.
      DisableBuiltinPDFViewer = false;
    };
    settings = {
      # Already LibreWolf's default; ask where to save every download.
      "browser.download.useDownloadDir" = false;
      "browser.toolbars.bookmarks.visibility" = "newtab";
      "browser.translations.automaticallyPopup" = false;
    };
  };

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
