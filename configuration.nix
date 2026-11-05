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
      "video"
    ];
    packages = with pkgs; [ ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Root and the claude-remote user see only these, not Home Manager's packages.
    helix
    git
    ntfs3g
    typst
    unzip
    chromium
    brightnessctl
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    noto-fonts
  ];

  environment.variables = {
    TERMINAL = "ghostty";
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXOS_OZONE_WL = "1";
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

  programs.chromium = {
    enable = true;
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    defaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
    extraOpts = {
      # Installed automatically but can be disabled, unlike the `extensions` option.
      ExtensionSettings =
        let
          normal = {
            installation_mode = "normal_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
        in
        {
          "ddkjiahejlhfcafbddmgiahcphecmpfh" = normal; # uBlock Origin Lite
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" = normal; # Dark Reader
        };
      DefaultSearchProviderName = "DuckDuckGo";
      # Passwords live in KeePassXC; Chromium's own store is only weakly encrypted.
      PasswordManagerEnabled = false;
      TranslateEnabled = false;
      DefaultBrowserSettingEnabled = false;
      # Ask where to save every download.
      PromptForDownloadLocation = true;

      # Privacy: no telemetry, Google web services, ad tracking, or account sync.
      MetricsReportingEnabled = false;
      UrlKeyedAnonymizedDataCollectionEnabled = false;
      SpellCheckServiceEnabled = false;
      AlternateErrorPagesEnabled = false;
      PrivacySandboxAdTopicsEnabled = false;
      PrivacySandboxSiteEnabledAdsEnabled = false;
      PrivacySandboxAdMeasurementEnabled = false;
      PrivacySandboxPromptEnabled = false;
      BlockThirdPartyCookies = true;
      NetworkPredictionOptions = 2;
      BrowserSignin = 0;
      SyncDisabled = true;
      GenAiDefaultSettings = 2;
      BackgroundModeEnabled = false;
      AutofillCreditCardEnabled = false;
      PaymentMethodQueryEnabled = false;
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "24.11";
}
