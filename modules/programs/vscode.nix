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
    modules.vscode.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables VSCode.
      '';
    };
  };

  config = lib.mkIf config.modules.vscode.enable {

    environment.systemPackages = with pkgs; [

      vscode-fhs

    ];

  };
}
