# --- VSCode ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.programming.vscode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables VSCode.
      '';
    };
  };

  config = lib.mkIf config.modules.programming.vscode {

    environment.systemPackages = with pkgs; [

      vscode-fhs

    ];

  };
}
