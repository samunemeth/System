# --- Lua ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.lua = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for Lua.
        Includes LSP server and formatter.
      '';
    };
  };

  config = lib.mkIf config.modules.code.lua {

    environment.systemPackages = with pkgs; [

      lua # Small, simple scripting language.
      lua-language-server # LSP server.
      stylua # Formatter.

    ];

  };
}
