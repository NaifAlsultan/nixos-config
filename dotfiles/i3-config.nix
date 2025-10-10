{ lib, ... }:

let
  mod = "Mod4";
in
{
  modifier = mod;
  keybindings = lib.mkOptionDefault {
    "${mod}+b" = "exec librewolf";
    "${mod}+m" = "exec obsidian";
    "${mod}+h" = "focus left";
    "${mod}+j" = "focus down";
    "${mod}+k" = "focus up";
    "${mod}+l" = "focus right";
    "${mod}+Shift+h" = "move left";
    "${mod}+Shift+j" = "move down";
    "${mod}+Shift+k" = "move up";
    "${mod}+Shift+l" = "move right";
    "${mod}+c" = "split h";
    XF86AudioRaiseVolume = "exec --no-startup-id wpctl set-volume @DEFAULT_SINK@ .05+";
    XF86AudioLowerVolume = "exec --no-startup-id wpctl set-volume @DEFAULT_SINK@ .05-";
    XF86AudioMute = "exec --no-startup-id wpctl set-mute @DEFAULT_SINK@ toggle";
  };
  modes.resize = {
    j = "resize grow height 10 px or 10 ppt";
    h = "resize shrink width 10 px or 10 ppt";
    l = "resize grow width 10 px or 10 ppt";
    k = "resize shrink height 10 px or 10 ppt";
    Escape = "mode default";
    Return = "mode default";
  };
}
