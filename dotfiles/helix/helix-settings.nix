{
  theme = "ayu_mirage";
  editor = {
    file-picker.hidden = false;
    line-number = "relative";
    idle-timeout = 5;
    completion-timeout = 5;
    inline-diagnostics.cursor-line = "error";
    lsp.auto-signature-help = false;
  };
  keys.normal.space.i = ":toggle lsp.display-inlay-hints";
}
