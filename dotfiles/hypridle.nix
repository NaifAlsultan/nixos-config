{
  services.hypridle = {
    enable = true;
    settings.listener = [
      {
        timeout = 600;
        on-timeout = ''hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' '';
        on-resume = ''hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' '';
      }
    ];
  };
}
