{
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
      "tray"
      "clock"
    ];

    "hyprland/workspaces" = {
      disable-scroll = true;
      sort-by-number = true;
    };
    network = {
      interval = 2;
      format-wifi = "W: {essid}";
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
    tray.spacing = 8;
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
      background: #1f2430;
      color: #cbccc6;
      border-bottom: 1px solid #323844;
    }

    #workspaces button {
      padding: 0 7px;
      color: #686868;
      background: transparent;
    }

    #workspaces button.active,
    #workspaces button.focused {
      color: #ffffff;
      background: #323844;
      box-shadow: inset 0 -2px #60b8d6;
    }

    #workspaces button.urgent {
      color: #1f2430;
      background: #f08778;
    }

    #network,
    #cpu,
    #memory,
    #disk,
    #pulseaudio,
    #battery,
    #tray,
    #clock {
      padding: 0 7px;
    }

    #clock {
      color: #ffffff;
    }
  '';
}
