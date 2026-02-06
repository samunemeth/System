# --- Zathura ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # Plugins to add to Zathura.
  zathura-plugins = with pkgs.zathuraPkgs; [
    zathura_pdf_mupdf
  ];
  zathura-package = (pkgs.zathura.override { plugins = zathura-plugins; });

  # Settings for Zathura.
  zathura-options = with globals.colors; {

    # Configure some colors.
    default-bg = background.main;
    default-fg = foreground.main;
    statusbar-bg = background.soft;
    statusbar-fg = foreground.main;
    inputbar-bg = background.main;
    inputbar-fg = foreground.main;
    notification-error-bg = foreground.error;
    completion-bg = background.contrast;
    completion-fg = foreground.main;
    completion-highlight-bg = foreground.soft;
    completion-highlight-fg = background.contrast;
    highlight-active-color = "rgba(85, 90, 240, 0.3)";
    highlight-color = "rgba(160, 235, 25, 0.3)";

    # Configure status bar.
    guioptions = "s";
    statusbar-basename = true;

    # Configure window title.
    window-title-home-tilde = true;

    # Copy selection to system clipboard.
    selection-clipboard = "clipboard";
    selection-notification = false;

    # Enable SyncTeX
    dbus-service = true;
    synctex = true;

    # Configure recoloring.
    recolor-keephue = true;
    recolor-reverse-video = false;
    recolor-lightcolor = background.contrast;
    recolor-darkcolor = foreground.soft;

    # Space between pages.
    page-v-padding = 1;
    page-h-padding = 1;

  };

  # Mappings for Zathura.
  # NOTE: This remaps keys to other keys, not functions.
  zathura-mappings = {

    # Aligns the page for navigations
    "zz" = "<S-P>";

    # Maps navigations keys for smooth scrolling
    "j" = "<C-Down>";
    "k" = "<C-Up>";
    "h" = "<C-Left>";
    "l" = "<C-Right>";

    # Better page navigation
    "<Space>" = "<PageDown>";
    "<S-Space>" = "<PageUp>";

  };

  # Functions for converting the configuration.
  formatMapLine = n: v: ''map ${n} feedkeys "${builtins.toString v}"'';
  formatSetLine =
    n: v:
    let
      formatValue = v: if lib.isBool v then (if v then "true" else "false") else builtins.toString v;
    in
    ''set ${n} "${formatValue v}"'';

  # Format the configuration file.
  zathura-config-text =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList formatSetLine zathura-options
      ++ lib.mapAttrsToList formatMapLine zathura-mappings
    )
    + "\n";

  # Put the configuration text in a file. The more complex writer is needed as
  # Zathura expects a configuration directory, not a file.
  zathura-home = pkgs.writeTextFile {
    name = "zathura-home";
    destination = "/zathurarc";
    text = zathura-config-text;
  };

  wrapped-zathura = pkgs.symlinkJoin {
    name = "wrapped-zathura";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ zathura-package ];
    postBuild = ''
      wrapProgram $out/bin/zathura \
        --add-flags "\
          --config-dir=${zathura-home} \
        "
    '';
  };

in
{

  options.modules = {
    apps.zathura = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the Zathura PDF reader.
      '';
    };
  };

  config =
    lib.mkAlwaysThenIf config.modules.apps.zathura
      {
        modules.export-apps.zathura = wrapped-zathura;
      }
      {

        # TODO: Include an environment variable for default pdf reader.
        environment.systemPackages = [ wrapped-zathura ];

      };

}
