{
  "tztime local" = {
    position = 6;
    settings.format = "%Y-%m-%d %I:%M %p";
  };
  memory = {
    position = 5;
    settings = {
      format = "Mem %percentage_used";
      threshold_degraded = "60%";
      threshold_critical = "40%";
    };
  };
  "disk /" = {
    position = 3;
    settings = {
      format = "Disk %free";
      low_threshold = 10;
      threshold_type = "percentage_avail";
    };
  };
  cpu_usage = {
    position = 4;
    settings = {
      format = "CPU %usage";
      max_threshold = 80;
      degraded_threshold = 40;
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
