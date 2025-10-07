{
  xsession.windowManager.i3 = {
    enable = true;
    config = import ./dotfiles/i3-config.nix;
  };

  programs.helix = {
    enable = true;
    settings = import ./dotfiles/helix/helix-settings.nix;
    languages = import ./dotfiles/helix/helix-langs.nix;
  };

  programs.alacritty = {
    enable = true;
    settings = import ./dotfiles/alacritty-settings.nix;
  };

  programs.git = import ./dotfiles/git-config.nix;

  programs.i3status = {
    enable = true;
    enableDefault = false;
    modules = import ./dotfiles/i3status-config.nix;
  };

  home.stateVersion = "24.11";
}
