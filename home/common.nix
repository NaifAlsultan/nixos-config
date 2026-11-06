{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    ../dotfiles/claude-code.nix
    ../dotfiles/ghostty.nix
    ../dotfiles/git.nix
    ../dotfiles/helix.nix
    ../dotfiles/starship.nix
  ];

  home.packages = with pkgs; [
    obsidian
    typst
    unzip
    nerd-fonts.symbols-only
    noto-fonts
  ];

  programs.nushell = {
    enable = true;
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

  programs.opencode = {
    enable = true;
    package = unstable.opencode;
    settings = {
      shell = "${pkgs.bash}/bin/bash";
      permission.external_directory = "allow";
    };
  };
}
