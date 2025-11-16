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
        Enables support for Java.
      '';
    };
  };

  config = lib.mkIf config.modules.programming.java {

    environment.systemPackages = with pkgs; [ jdk17 ];

  };
}
