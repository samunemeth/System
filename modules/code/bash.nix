# --- Bash ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.bash = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables additional support for Bash.
        Includes formatter.
      '';
    };
  };

  config = lib.mkIf config.modules.code.bash {

    environment.systemPackages = with pkgs; [

      beautysh # Formatter.

    ];

  };
}
