{ config, pkgs, inputs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;

  services.udev.packages = [ pkgs.brightnessctl ];

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Riyadh";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

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
      "docker"
      "video"
    ];
    packages = with pkgs; [ ];
  };

  virtualisation.docker.enable = true;
  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    helix
    librewolf
    git
    ghostty
    ntfs3g
    keepassxc
    obsidian
    typst
    dropbox
    vscode
    unzip
    chromium
    libreoffice
    kdePackages.kate
    zathura
    burpsuite
    brightnessctl
  ];

  fonts.packages = with pkgs; [ noto-fonts ];

  environment.variables = {
    TERMINAL = "ghostty";
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.shellAliases = {
    c = "wl-copy";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = false;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.hyprland.package}/bin/start-hyprland";
  };

  security.pam.services.hyprlock = { };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8081 ];

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "24.11";
}
