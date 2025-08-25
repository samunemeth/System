# --- Zathura ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  programs.zathura = {

    enable = true;

    options = {

# Configure status bar
      "guioptions" = "s";
      "statusbar-bg" = "#00000000";
      "statusbar-fg" = "#999999";
      "statusbar-basename" = "true";

# Configure notifications
      "notification-bg" = "#BBBBBB";
      "notification-fg" = "#000000";

# Configure window title
      "window-title-home-tilde" = "true";

# Copy selection to system clipboard
      "selection-clipboard" = "clipboard";

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
