{ pkgs, ... }:

{
  wayland.systemd.target = "hyprland-session.target";

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    systemd.enable = true;
    extraConfig = import ./dotfiles/hyprland-config.nix;
  };

  home.packages = [ pkgs.wl-clipboard ];

  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    dotIcons.enable = false;
    gtk.enable = true;
  };

  gtk.enable = true;

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "ghostty";
        font = "monospace:size=11";
        width = 50;
        lines = 12;
        horizontal-pad = 16;
        vertical-pad = 12;
      };
      colors = {
        background = "1f2430ff";
        text = "cbccc6ff";
        match = "60b8d6ff";
        selection = "323844ff";
        selection-text = "ffffffff";
        border = "60b8d6ff";
      };
      border = {
        width = 1;
        radius = 0;
      };
    };
  };

  programs.waybar = import ./dotfiles/waybar-config.nix;

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
          color = "rgb(1f2430)";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "240, 48";
          outline_thickness = 1;
          outer_color = "rgb(60b8d6)";
          inner_color = "rgb(212733)";
          font_color = "rgb(cbccc6)";
          fade_on_empty = false;
          placeholder_text = "Password";
        }
      ];
    };
  };

  services.hyprpolkitagent.enable = true;

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      background-color = "#1f2430";
      border-color = "#60b8d6";
      border-radius = 0;
      border-size = 1;
      default-timeout = 5000;
      font = "monospace 10";
      text-color = "#cbccc6";
    };
  };

  services.hyprsunset = {
    enable = true;
    settings.profile = [
      {
        time = "06:00";
        temperature = 5500;
      }
      {
        time = "18:00";
        temperature = 3700;
      }
    ];
  };

  programs.helix = {
    enable = true;
    settings = import ./dotfiles/helix/helix-settings.nix;
    languages = import ./dotfiles/helix/helix-langs.nix;
  };

  programs.ghostty = {
    enable = true;
    clearDefaultKeybinds = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
    installBatSyntax = false;
    systemd.enable = false;
    settings = import ./dotfiles/ghostty-settings.nix;
  };

  programs.git = import ./dotfiles/git-config.nix;

  programs.zathura = import ./dotfiles/zathura-config.nix;

  home.stateVersion = "24.11";
}
