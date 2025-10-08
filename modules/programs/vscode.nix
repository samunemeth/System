# --- VSCode ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{
  config = lib.mkIf config.modules.packages.programming {

    environment.systemPackages = with pkgs; [

      vscode-fhs

    ];

  };
}
