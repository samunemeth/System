# --- Bash ---

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

      programs.bash = {

        enable = true;

        # Aliases for NixOS related functions and other short alternatives.
        shellAliases = {

          "nec" = "( cd ~/System ; nvim flake.nix )";
          "nfu" = "( cd ~/System ; nix flake update )";
          "ncg" = "sudo nix-collect-garbage -d";

          "snvim" = "sudo -E nvim";
          "fetch" = "fastfetch";

        };

        # Alias for building NixOS and custom bash prompt.
        initExtra = # bash
          ''

            nrs () {
              sudo nixos-rebuild switch --flake ~/System/#$1
            }

            export PS1='\[\e[92m\]\u\[\e[2;3m\]@\h\[\e[0;1m\]:\[\e[96m\]\w\[\e[39m\]\$\[\e[0m\] '

            pkgs () {
              nix-shell --command "PS1='\[\e[95;2m\][nix-shell]\[\e[0m\] $PS1'; return" -p "$@"
            }

            diskspace () {
              sudo du -cha --max-depth=1 $1 | sort -hr | head -n -1 | rg "^[\d\.]+[MG]" --color=never
            }

          '';

      };

      # User session variables, for ease of user.
      home.sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "firefox";
        TERMINAL = "alacritty";
      };

    };
}
