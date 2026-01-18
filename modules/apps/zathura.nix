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

        options = with globals.colors; {

          # Configure some colors.
          "default-bg" = background.main;
          "default-fg" = foreground.main;
          "statusbar-bg" = background.soft;
          "statusbar-fg" = foreground.main;
          "inputbar-bg" = background.main;
          "inputbar-fg" = foreground.main;
          "notification-error-bg" = foreground.error;

          # Configure status bar.
          "guioptions" = "s";
          "statusbar-basename" = "true";

          # Configure window title.
          "window-title-home-tilde" = "true";

          # Copy selection to system clipboard>
          "selection-clipboard" = "clipboard";
          "selection-notification" = "false";

          # Configure recoloring.
          "recolor-keephue" = "true";
          "recolor-reverse-video" = "false";
          "recolor-lightcolor" = background.contrast;
          "recolor-darkcolor" = foreground.soft;

          # Space between pages.
          "page-v-padding" = "5";
          "page-h-padding" = "5";


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
