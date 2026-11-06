{
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
}
