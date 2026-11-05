{
  programs.helix = {
    enable = true;

    settings = {
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
      keys.normal.space.m = ":toggle inline-diagnostics.cursor-line hint";
    };

    languages = {
      language-server = {
        harper-ls = {
          command = "harper-ls";
          args = [ "--stdio" ];
        };
      };
      language = [
        {
          name = "html";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "html"
            ];
          };
          auto-format = true;
        }
        {
          name = "css";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "css"
            ];
          };
          auto-format = true;
        }
        {
          name = "typescript";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
          auto-format = true;
        }
        {
          name = "tsx";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
          auto-format = true;
        }
        {
          name = "json";
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "json"
            ];
          };
          auto-format = true;
        }
        {
          name = "rust";
          formatter = {
            command = "rustfmt";
          };
          auto-format = true;
        }
        {
          name = "markdown";
          language-servers = [ "harper-ls" ];
          soft-wrap = {
            enable = true;
            wrap-indicator = "";
          };
        }
      ];
    };
  };
}
