{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./system/chromium.nix ];

  boot.loader.systemd-boot.enable = true;
  # /boot is only 512 MB and each generation keeps a kernel there.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;

  services.udev.packages = [ pkgs.brightnessctl ];

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Riyadh";

  i18n.defaultLocale = "en_US.UTF-8";

  services.keyd = {
    enable = true;
    keyboards.default = {
      settings.main = {
        capslock = "esc";
        rightcontrol = "capslock";
      };
    };
  };

  users.users.naif = {
    isNormalUser = true;
    description = "naif";
    shell = pkgs.nushell;
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    TERMINAL = "ghostty";
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXOS_OZONE_WL = "1";
  };

  programs.hyprland = {
    enable = true;
    # Ties the session's services to Hyprland, so logging out stops them.
    withUWSM = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd '${lib.getExe config.programs.uwsm.package} start hyprland.desktop'";
  };

  security.pam.services.hyprlock = { };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Flakes only: no unpinned channels alongside the flake's nixpkgs.
  nix.channel.enable = false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "24.11";
}
