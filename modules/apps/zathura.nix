# --- Zathura ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      programs.zathura = {

        enable = true;
        package = (pkgs.zathura.override { plugins = with pkgs.zathuraPkgs; [ zathura_pdf_mupdf ]; });

        options = {

          # Configure status bar
          "guioptions" = "s";
          "statusbar-bg" = globals.colors.background.contrast;
          "statusbar-fg" = globals.colors.foreground.main;
          "statusbar-basename" = "true";

          # Configure notifications
          "notification-bg" = globals.colors.foreground.soft;
          "notification-fg" = globals.colors.background.contrast;

          # Configure window title
          "window-title-home-tilde" = "true";

          # Copy selection to system clipboard
          "selection-clipboard" = "clipboard";

          "recolor-keephue" = "true";
          "recolor-reverse-video" = "false";
          "recolor-lightcolor" = globals.colors.background.main;
          "recolor-darkcolor" = globals.colors.foreground.main;

        };

        mappings = {

          # Aligns the page for navigations
          "zz" = "feedkeys \"<S-P>\"";

          # Maps navigations keys for smooth scrolling
          "j" = "feedkeys \"<C-Down>\"";
          "k" = "feedkeys \"<C-Up>\"";
          "h" = "feedkeys \"<C-Left>\"";
          "l" = "feedkeys \"<C-Right>\"";

          # Better page navigation
          "<Space>" = "feedkeys \"<PageDown>\"";
          "<S-Space>" = "feedkeys \"<PageUp>\"";

        };

      };

    };
}
