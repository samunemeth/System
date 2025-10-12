# --- Java ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.programming.java = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Java.
      '';
    };
  };

  config = lib.mkIf config.modules.programming.java {

    environment.systemPackages = with pkgs; [

      jdk17

    ];

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        home.file.".config/checkstyle_config.xml".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/code/checkstyle_config.xml";

      };

  };
}
