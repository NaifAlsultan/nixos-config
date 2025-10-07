{
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
      soft-wrap = {
        enable = true;
        wrap-indicator = "";
      };
    }
  ];
}
