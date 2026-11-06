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
    ../dotfiles/keepassxc.nix
    ../dotfiles/starship.nix
    ../dotfiles/zathura.nix
  ];

  home.packages = with pkgs; [
    obsidian
    libreoffice
  ];

  # Uses LibreWolf's own defaults (uBlock Origin, DuckDuckGo, privacy settings)
  # and adds only what differs. No `profiles`, so the existing profile is kept.
  programs.librewolf = {
    enable = true;
    policies = {
      ExtensionSettings."addon@darkreader.org" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        installation_mode = "normal_installed";
      };
      # Open PDF links in the built-in viewer instead of downloading them.
      DisableBuiltinPDFViewer = false;
    };
    settings = {
      # Already LibreWolf's default; ask where to save every download.
      "browser.download.useDownloadDir" = false;
      "browser.toolbars.bookmarks.visibility" = "newtab";
      "browser.translations.automaticallyPopup" = false;
    };
  };

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
