let
  theme = import ./theme.nix;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [
        {
          monitor = "";
          color = "rgb(${theme.background})";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "240, 48";
          outline_thickness = 1;
          outer_color = "rgb(${theme.accent})";
          inner_color = "rgb(${theme.backgroundAlt})";
          font_color = "rgb(${theme.foreground})";
          fade_on_empty = false;
          placeholder_text = "Password";
        }
      ];
    };
  };
}
