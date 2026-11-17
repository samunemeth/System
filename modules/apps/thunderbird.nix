# --- Thunderbird ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    apps.thunderbird = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Thunderbird mail client.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.thunderbird {

    # TODO: Try to do some declarative configuration here.
    # > At least the GPG keys should be managed by sops.

    environment.systemPackages = with pkgs; [ thunderbird ];

  };
}
