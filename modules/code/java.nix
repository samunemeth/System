# --- Java ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.java = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for Java.
      '';
    };
  };

  config = lib.mkIf config.modules.code.java {

    environment.systemPackages =
      with pkgs;
      let
        java-package = jdk25;
      in
      [
        java-package
        (maven.override { jdk_headless = java-package; })
        (checkstyle.override { jre = java-package; })
      ];

  };
}
