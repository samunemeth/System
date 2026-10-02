# --- TLAPlus  ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.tlaplus = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for TLA+.
      '';
    };
  };

  config = lib.mkIf config.modules.code.tlaplus {

    environment.systemPackages = with pkgs; [

      tlaplus-toolbox

    ];

  };
}
