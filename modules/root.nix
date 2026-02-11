# --- Root for Modules ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}:
let

  # Read all the modules that are in subdirectories to this directory.
  # This way the templates that are on this level are excluded.
  module-folders = lib.attrNames (
    lib.filterAttrs (key: value: value == "directory") (builtins.readDir ./.)
  );
  modules-to-import = lib.flatten (
    map (
      folder: map (file: ./${folder}/${file}) (lib.attrNames (builtins.readDir ./${folder}))
    ) module-folders
  );

in
{

  # Import all the modules.
  imports = modules-to-import;

  options.modules = {
    export-apps = lib.mkOption {
      type = with lib.types; attrsOf package;
      default = { };
      example = "{ neovim = wrapped-neovim; }";
      description = ''
        A list of packages to expose under the specified name from the flake.
      '';
    };
  };

  config = { };

}
