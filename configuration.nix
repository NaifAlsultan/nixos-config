{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
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

  location = {
    longitude = 46.72185;
    latitude = 24.68773;
  };

  services.xserver.xkb = {
    layout = "us,ara";
    options = "grp:caps_toggle";
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
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
  };

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    helix
    librewolf
    git
    alacritty
    i3
    ntfs3g
    keepassxc
    xclip
    obsidian
    typst
    dropbox
    vscode
    redshift
    unzip
    chromium
    libreoffice
  ];

  fonts.packages = with pkgs; [ noto-fonts ];

  environment.variables = {
    TERMINAL = "alacritty";
  };

  environment.shellAliases = {
    kp = "keepassxc";
  };

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
  };

  services.redshift.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8081 ];

  system.stateVersion = "24.11";
}
