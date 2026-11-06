{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    # Copies to the clipboard: wl-copy on Wayland, pbcopy on macOS.
    shellAliases.c = if pkgs.stdenv.hostPlatform.isDarwin then "pbcopy" else "wl-copy";
    settings = {
      color_config.shape_garbage = "red";
      show_banner = false;
      completions.algorithm = "fuzzy";
      history = {
        file_format = "sqlite";
        isolation = false;
        max_size = 100000;
        sync_on_enter = true;
      };
    };
  };
}
