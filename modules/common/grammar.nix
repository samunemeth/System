# --- Grammar Checking ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    locale.grammar = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for grammar checking via LTeX+.
        This takes up ~800MiB of space.
      '';
    };
  };

  config = lib.mkIf config.modules.locale.grammar {

    environment.systemPackages = with pkgs; [
    
      ltex-ls-plus

    ];

  };
}
