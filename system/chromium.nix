{
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
}
