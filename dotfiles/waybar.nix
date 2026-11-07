let
  theme = import ./theme.nix;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 24;

      modules-left = [ "hyprland/workspaces" ];
      modules-right = [
        "network"
        "cpu"
        "memory"
        "disk"
        "pulseaudio"
        "battery"
        "clock"
      ];

      "hyprland/workspaces" = {
        disable-scroll = true;
        sort-by-number = true;
      };
      network = {
        interval = 2;
        format-wifi = "{essid}";
        format-ethernet = "E: {bandwidthDownBits}";
        format-disconnected = "Net: down";
        tooltip = false;
      };
      cpu = {
        interval = 2;
        format = "CPU {usage}%";
      };
      memory = {
        interval = 2;
        format = "Mem {percentage}%";
      };
      disk = {
        interval = 30;
        path = "/";
        format = "Disk {free}";
      };
      pulseaudio = {
        format = "Vol {volume}%";
        format-muted = "Vol muted";
      };
      battery = {
        interval = 30;
        format = "Bat {capacity}%";
      };
      clock = {
        interval = 30;
        format = "{:%Y-%m-%d %I:%M %p}";
        tooltip = false;
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: monospace;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: #${theme.background};
        color: #${theme.foreground};
        border-bottom: 1px solid #${theme.surface};
      }

      #workspaces button {
        padding: 0 7px;
        color: #${theme.muted};
        background: transparent;
      }

      #workspaces button.active,
      #workspaces button.focused {
        color: #${theme.white};
        background: #${theme.surface};
        box-shadow: inset 0 -2px #${theme.accent};
      }

      #workspaces button.urgent {
        color: #${theme.background};
        background: #${theme.red};
      }

      #network,
      #cpu,
      #memory,
      #disk,
      #pulseaudio,
      #battery,
      #clock {
        padding: 0 7px;
      }

      #clock {
        color: #${theme.white};
      }
    '';
  };
}
