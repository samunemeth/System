# --- Zathura ---

{ config, pkgs, lib, globals, ... }:
let

  # --- Color Settings ---
  colors = {
    background = {
      main = "#14161B";
      contrast = "#0A0B0E";
    };
    foreground = {
      main = "#F2F4F3";
      soft = "#D0D6DD";
      error = "#DC4332";
    };
  };

in
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  programs.zathura = {

    enable = true;
    package = (pkgs.zathura.override { plugins = with pkgs.zathuraPkgs; [ zathura_pdf_mupdf ]; });

    options = {

      # Configure status bar
      "guioptions" = "s";
      "statusbar-bg" = colors.background.contrast;
      "statusbar-fg" = colors.foreground.main;
      "statusbar-basename" = "true";

      # Configure notifications
      "notification-bg" = colors.foreground.soft;
      "notification-fg" = colors.background.contrast;

      # Configure window title
      "window-title-home-tilde" = "true";

      # Copy selection to system clipboard
      "selection-clipboard" = "clipboard";

      "recolor" = "true";
      "recolor-keephue" = "true";
      "recolor-reverse-video" = "false";
      "recolor-lightcolor" = colors.background.main;
      "recolor-darkcolor" = colors.foreground.main;

    };

    mappings = {

      # Aligns the page for navigations
      "zz" = "feedkeys \"<S-P>\"";

      # Maps navigations keys for smooth scrolling
      "j" = "feedkeys \"<C-Down>\"";
      "k" = "feedkeys \"<C-Up>\"";
      "h" = "feedkeys \"<C-Left>\"";
      "l" = "feedkeys \"<C-Right>\"";

    };

  };

  };
}
