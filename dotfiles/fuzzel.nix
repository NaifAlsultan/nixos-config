let
  theme = import ./theme.nix;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "ghostty";
        # Starts each app in its own systemd unit.
        launch-prefix = "uwsm app --";
        font = "monospace:size=11";
        width = 50;
        lines = 12;
        horizontal-pad = 16;
        vertical-pad = 12;
      };
      colors = {
        background = "${theme.background}ff";
        text = "${theme.foreground}ff";
        match = "${theme.accent}ff";
        selection = "${theme.surface}ff";
        selection-text = "${theme.white}ff";
        border = "${theme.accent}ff";
      };
      border = {
        width = 1;
        radius = 0;
      };
    };
  };
}
