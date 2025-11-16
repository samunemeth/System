# --- Firefox ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    apps.firefox = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the Firefox browser.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.firefox {

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        programs.firefox.enable = true;

        programs.firefox.policies = {

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
          SearchEngines = {
            Default = "DuckDuckGo";
          };
          ShowHomeButton = false;

          # Extensions.
          ExtensionSettings = {

            # Block installation of other extensions.
            "*".installation_mode = "blocked";

            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };

          };

          # Preferences that control the browser behaviour.
          Preferences = {
            "extensions.pocket.enabled" = {
              Value = false;
              Status = "locked";
            };
            "browser.theme.toolbar-theme" = {
              Value = if globals.colors.dark then 0 else 1;
              Type = "number";
              Status = "locked";
            };
            "browser.theme.content-theme" = {
              Value = if globals.colors.dark then 0 else 1;
              Type = "number";
              Status = "locked";
            };
          };

        };

      };

  };
}
