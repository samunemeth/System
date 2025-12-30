# --- Rust ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.rust = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for Rust.
        Includes LSP server, formatter, Neovim plugin,
        and Cargo for package management.
      '';
    };
  };

  config = lib.mkIf config.modules.code.rust {

    environment.systemPackages = with pkgs; [

      cargo # Package manager for Rust.
      rustfmt # Formatter for Rust files.
      rust-analyzer # LSP for Rust.
      rustc # Analytics for Rust.

    ];

  };
}
