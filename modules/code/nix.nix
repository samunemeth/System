# --- Nix ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.nix = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables additional support for Nix.
        Includes LSP server.
      '';
    };
  };

  config = lib.mkIf config.modules.code.nix {

    environment.systemPackages = with pkgs; [

      nixd # LSP server.

    ];

  };
}
