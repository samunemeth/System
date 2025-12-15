# --- Haskell ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.haskell = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for Haskell.
      '';
    };
  };

  config = lib.mkIf config.modules.code.haskell {

    environment.systemPackages = with pkgs; [

      # Haskell with libraries.
      (haskellPackages.ghcWithPackages (p: with p; [

        hmatrix # Matrix math package for Haskell.

      ]))

      haskell-language-server # LSP server.
      ormolu # Code formatter for Haskell.

    ];

  };
}
