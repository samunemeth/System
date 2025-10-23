# --- Rust ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.programming.rust = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Rust.
      '';
    };
  };

  config = lib.mkIf config.modules.programming.rust {

    environment.systemPackages = with pkgs; [

      cargo
      rustfmt
      rust-analyzer
      rustc

    ];

  };
}
