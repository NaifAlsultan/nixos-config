{ pkgs, ... }:

let
  theme = import ./theme.nix;
in
{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = true;
      format = "$directory$git_branch$custom ";
      directory = {
        format = "[ $path ]($style)";
        style = "bold fg:#${theme.background} bg:#${theme.accent}";
        truncate_to_repo = false;
        truncation_length = 0;
      };
      git_branch = {
        format = "[](fg:#${theme.accent} bg:#${theme.yellow})[  $branch ]($style)[](fg:#${theme.yellow})";
        style = "bold fg:#${theme.background} bg:#${theme.yellow}";
        symbol = "";
      };
      custom.directory_tail = {
        command = "printf ''";
        format = "[$output]($style)";
        shell = [ "${pkgs.bash}/bin/bash" ];
        style = "fg:#${theme.accent}";
        when = "! git rev-parse --is-inside-work-tree >/dev/null 2>&1";
      };
    };
  };
}
