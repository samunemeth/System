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
        Includes LSP server, formatter, and Neovim plugin.
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
      ormolu # Formatter.

    ];

  };
}
