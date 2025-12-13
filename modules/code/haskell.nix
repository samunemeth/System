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

      # Haskell with packages.
      (haskellPackages.ghcWithPackages (pkgs: with pkgs; [

        # turtle # Running Haskell as a shell script.
        # cabal-install # Project manager for Haskell.
        haskell-language-server # LSP server.

        hmatrix # Matrix math package for Haskell.

      ]))

      ormolu # Code formatter for Haskell.

    ];

  };
}
