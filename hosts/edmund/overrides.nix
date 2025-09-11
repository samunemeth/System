# --- Overrides for Joseph ---

{ config, pkgs, lib, globals, ... }:
{

  nixpkgs.hostPlatform = "x86_64-linux";
  wsl.enable = true;
  wsl.defaultUser = globals.user;

  # Set time zone to CET.
  time.timeZone = "Europe/Amsterdam";

  # Select the en_US locale, as this is the default,
  # and should be supported by all programs.
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

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {



  };
}
