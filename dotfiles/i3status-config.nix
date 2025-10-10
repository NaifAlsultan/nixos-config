{
  "tztime local" = {
    position = 8;
    settings.format = "%Y-%m-%d %I:%M %p";
  };
  memory = {
    position = 7;
    settings = {
      format = "Mem %percentage_used";
      threshold_degraded = "60%";
      threshold_critical = "40%";
    };
  };
  "disk /" = {
    position = 5;
    settings = {
      format = "Disk %free";
      low_threshold = 10;
      threshold_type = "percentage_avail";
    };
  };
  cpu_usage = {
    position = 6;
    settings = {
      format = "CPU %usage";
      max_threshold = 80;
      degraded_threshold = 40;
    };
  };
  "battery 0" = {
    position = 4;
    settings = {
      format = "%percentage (%status)";
      low_threshold = 20;
      threshold_type = "percentage";
      last_full_capacity = true;
      path = "/sys/class/power_supply/BAT0/uevent";
    };
  };
  "volume master" = {
    position = 3;
    settings = {
      format = "Vol: %volume";
      format_muted = "Vol: muted";
      device = "default";
    };
  };
  "ethernet _first_" = {
    position = 2;
    settings = {
      format_up = "E: %speed";
      format_down = "E: down";
    };
  };
  "wireless _first_" = {
    position = 1;
    settings = {
      format_up = "W: %essid";
      format_down = "W: down";
    };
  };
}
