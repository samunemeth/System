# --- Tmux ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  wrapped-tmux = pkgs.tmux;

in
{

  options.modules = {
    apps.tmux = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables Tmux.
      '';
    };
  };

  config =
    lib.mkAlwaysThenIf config.modules.apps.tmux
      {
        modules.export-apps.tmux = wrapped-tmux;
      }
      {

        environment.systemPackages = [ wrapped-tmux ];

      };

}
