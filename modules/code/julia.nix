# --- Julia ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.julia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for Julia.
      '';
    };
  };

  config = lib.mkIf config.modules.code.julia {

    environment.systemPackages = with pkgs; [ julia ];

  };
}
