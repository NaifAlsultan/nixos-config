{ lib, ... }:

let
  theme = import ./theme.nix;
in
{
  programs.ghostty = {
    enable = true;
    clearDefaultKeybinds = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
    installBatSyntax = false;
    systemd.enable = false;
    settings = {
      background = "#${theme.background}";
      foreground = "#${theme.foreground}";

      palette = lib.imap0 (i: c: "${toString i}=#${c}") theme.ansi;

      # Keep Ghostty as a single-surface terminal, like Alacritty.
      gtk-single-instance = false;
      gtk-titlebar = false;
      window-decoration = "server";
      window-show-tab-bar = "never";
      right-click-action = "ignore";

      shell-integration = "none";
      cursor-click-to-move = false;
      copy-on-select = false;
      clipboard-read = "deny";
      clipboard-paste-protection = false;
      confirm-close-surface = false;

      app-notifications = false;
      desktop-notifications = false;
      progress-style = false;
      bell-features = false;
      command-palette-entry = "";
      link-previews = false;
      resize-overlay = "never";
      scrollbar = "never";
      image-storage-limit = 0;

      font-feature = "-calt,-liga,-dlig";
      window-padding-x = 0;
      window-padding-y = 0;

      keybind = [
        "Copy=copy_to_clipboard:plain"
        "Paste=paste_from_clipboard"
        "ctrl+shift+c=copy_to_clipboard:plain"
        "ctrl+shift+v=paste_from_clipboard"
        "shift+insert=paste_from_selection"
        "ctrl+0=reset_font_size"
        "ctrl+equal=increase_font_size:1"
        "ctrl+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+numpad_add=increase_font_size:1"
        "ctrl+numpad_subtract=decrease_font_size:1"
        "shift+page_up=scroll_page_up"
        "shift+page_down=scroll_page_down"
        "shift+home=scroll_to_top"
        "shift+end=scroll_to_bottom"
        "ctrl+shift+f=start_search"
        "performable:escape=end_search"
      ];
    };
  };
}
