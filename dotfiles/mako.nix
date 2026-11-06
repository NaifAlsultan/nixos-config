let
  theme = import ./theme.nix;
in
{
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
}
