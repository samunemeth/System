# --- Firefox ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # Add policies and preferences for Firefox.
  # Policies are a bit like global settings, while preferences are more like
  # user specific settings. They do not make a difference here.
  # I split the configuration up a bit more than these two, as it quickly
  # becomes unreadable otherwise.

  # NOTE: Most of this is just boilerplate. You can set this up in
  # > Firefox, then copying and transforming the resulting value.
  custom-toolbar = {
    placements = {
      widget-overflow-fixed-list = [ ];
      unified-extensions-area = [
        "ublock0_raymondhill_net-browser-action"
        "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
      ];
      nav-bar = [
        "back-button"
        "forward-button"
        "stop-reload-button"
        "customizableui-special-spring1"
        "vertical-spacer"
        "urlbar-container"
        "customizableui-special-spring2"
        "downloads-button"
        "fxa-toolbar-menu-button"
        "unified-extensions-button"
      ];
      toolbar-menubar = [ "menubar-items" ];
      TabsToolbar = [
        "tabbrowser-tabs"
        "new-tab-button"
      ];
      vertical-tabs = [ ];
      PersonalToolbar = [ "personal-bookmarks" ];
    };
    seen = [
      "ublock0_raymondhill_net-browser-action"
      "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
      "developer-button"
      "screenshot-button"
    ];
    dirtyAreaCache = [
      "unified-extensions-area"
      "nav-bar"
      "vertical-tabs"
      "TabsToolbar"
      "toolbar-menubar"
      "PersonalToolbar"
    ];
    currentVersion = 23;
    newElementCount = 4;
  };

  # Available: https://mozilla.github.io/policy-templates/#preferences
  # Detailed available: https://searchfox.org/firefox-main/source/modules/libpref/init/StaticPrefList.yaml
  # Current: about:config
  custom-preferences = {

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
    "browser.uiCustomization.state" = {
      Value = builtins.toJSON custom-toolbar; # This is declared above.
      Type = "string";
      Status = "locked";
    };

  };

  # You have to hunt for these IDs, I do not remember where.
  custom-extensions = {

    # Block installation of other extensions.
    "*".installation_mode = "blocked";

    # uBlock Origin
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
    };

    # Bitwarden
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      installation_mode = "force_installed";
    };

  };

  # Available: https://mozilla.github.io/policy-templates/
  # Current: about:policies
  custom-policies = {

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

    # These are declared above.
    ExtensionSettings = custom-extensions;
    Preferences = custom-preferences;

  };

in
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

    # Update environment settings.
    environment.sessionVariables.BROWSER = "firefox";

    # Enable Firefox with the policies.
    programs.firefox = {
      enable = true;
      policies = custom-policies;
    };

  };
}
