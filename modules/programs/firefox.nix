# --- Firefox --- 

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  programs.firefox = {
  
    enable = true;
  
    policies = {
  
      # Simple policies.
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisplayBookmarksToolbar = "always";
      Cookies = {
        Behavior = "reject-tracker-and-partition-foreign";
        Locked = true;
      };
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = false;
        FormData = false;
        History = false;
        Sessions = false;
        SiteSettings = false;
        Locked = true;
      };
      AutofillCreditCardEnabled = false;
  
      # Extensions.
      ExtensionSettings = {
  
        # Block installation of other extensions.
        "*".installation_mode = "blocked";
  
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
  
        # Cameleon
        "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/cameleon-ext/latest.xpi";
          installation_mode = "force_installed";
        };
  
      };
  
      # Preferences that control the browser behaviour.
      Preferences = let
  
        # Define some useful data types.
        lock-false = {
          Value = false;
          Status = "locked";
        };
        lock-true = {
          Value = true;
          Status = "locked";
        };
  
      in {
  
        # List all the settings here.
        "extensions.pocket.enabled" = lock-false;
        "browser.theme.toolbar-theme" = {
          Value = 0;
          Type = "number";
          Status = "locked";
        };
        "browser.theme.content-theme" = {
          Value = 0;
          Type = "number";
          Status = "locked";
        };
  
      };
    };

  };

  };
}
