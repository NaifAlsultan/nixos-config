{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./system/agent-browser.nix
    ./system/brightness.nix
    ./system/chromium.nix
  ];

  boot.loader.systemd-boot.enable = true;
  # /boot is only 512 MB and each generation keeps a kernel there.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  system.preSwitchChecks.matchingHost = ''
    current=$(< /proc/sys/kernel/hostname)
    if [[ "$current" != ${lib.escapeShellArg config.networking.hostName} && "$current" != nixos ]]; then
      echo "This is '$current', but the configuration is for '${config.networking.hostName}'." >&2
      echo "Run: sudo nixos-rebuild switch --flake ." >&2
      exit 1
    fi
  '';

  hardware.enableRedistributableFirmware = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Riyadh";

  i18n.defaultLocale = "en_US.UTF-8";

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
    ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.variables.NIXOS_OZONE_WL = "1";

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

  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "24.11";
}
