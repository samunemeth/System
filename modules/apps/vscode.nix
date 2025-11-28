# --- VSCode ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    apps.vscode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables VSCode.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.vscode {

    environment.systemPackages = with pkgs; [ vscode-fhs ];

  };
}
