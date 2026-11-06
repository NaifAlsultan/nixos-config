{ lib, pkgs, ... }:

let
  theme = import ./theme.nix;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  # The Mac uses cmd where Linux uses ctrl (or ctrl+shift, since ctrl+c
  # interrupts the running program).
  mod = if isDarwin then "cmd" else "ctrl";
  shiftMod = if isDarwin then "cmd" else "ctrl+shift";
in
{
  programs.ghostty = {
    enable = true;
    # The Linux package doesn't build on macOS; ghostty-bin is the official app.
    package = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
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
        "${shiftMod}+c=copy_to_clipboard:plain"
        "${shiftMod}+v=paste_from_clipboard"
        "shift+insert=paste_from_selection"
        "${mod}+0=reset_font_size"
        "${mod}+equal=increase_font_size:1"
        "${mod}+plus=increase_font_size:1"
        "${mod}+minus=decrease_font_size:1"
        "${mod}+numpad_add=increase_font_size:1"
        "${mod}+numpad_subtract=decrease_font_size:1"
        "shift+page_up=scroll_page_up"
        "shift+page_down=scroll_page_down"
        "shift+home=scroll_to_top"
        "shift+end=scroll_to_bottom"
        "${shiftMod}+f=start_search"
        "performable:escape=end_search"
        # Opens in the current terminal's folder, which Nushell reports.
        "${shiftMod}+n=new_window"
      ];
    };
  };
}
