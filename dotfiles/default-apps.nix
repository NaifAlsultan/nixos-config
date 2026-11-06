{
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
