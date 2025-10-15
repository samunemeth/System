# --- Bash ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # A nicer terminal only interface if needed.
  services.kmscon = {
    enable = true;
    fonts = [
      {
        name = "Hack Nerd Font Mono";
        package = pkgs.nerd-fonts.hack;
      }
    ];
    hwRender = true;
    useXkbConfig = true;
    extraConfig = ''

      login=/bin/bash -i
      font-size=14

      palette=custom
      palette-red=172, 66, 66
      palette-light-red=172, 66, 66
      palette-green=144, 169, 89
      palette-light-green=144, 169, 89
      palette-yellow=24, 191, 117
      palette-light-yellow=24, 191, 117
      palette-blue=106, 159, 181
      palette-light-blue=106, 159, 181
      palette-magenta=170, 117, 159
      palette-light-magenta=170, 117, 159
      palette-cyan=117, 181, 170
      palette-light-cyan=117, 181, 170
      palette-black=20, 22, 27
      palette-background=20, 22, 27
      palette-dark-grey=100, 100, 100
      palette-white=242, 244, 243
      palette-foreground=242, 244, 243
      palette-light-grey= 200, 200, 200

    '';
  };

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
          "nes" = "( cd ~/System ; sops secrets.yaml )";
          "nfu" = "( cd ~/System ; nix flake update )";
          "ncg" = "sudo nix-collect-garbage -d";

          "snvim" = "sudo -E nvim";
          "clip" = "xclip -selection clipboard";
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
              du -cha --max-depth=1 $1 | sort -hr | head -n -1 | rg "^[\d\.]+[MG]" --color=never
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
