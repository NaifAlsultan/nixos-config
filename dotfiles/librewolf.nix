{
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
}
