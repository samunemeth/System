# --- Git ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  programs.git = {

    enable = true;

    config = {

      # Configure default name and email.
      user.name = globals.name;
      user.email = globals.email;

      # Use rebase for pull request conflicts.
      pull.rebase = true;

    };

  };
}
