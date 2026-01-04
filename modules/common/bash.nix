# --- Bash ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = { };

  config = {

    # Aliases for NixOS related functions and other short alternatives.
    programs.bash = {

      shellAliases = {

        # Edit NixOS configuration.
        "nec" = "( cd ~/System ; $EDITOR flake.nix )";

        # Update NixOS flake.
        "nfu" = "( cd ~/System ; nix flake update )";

        # Collect NixOS garbage.
        "ncg" = "sudo nix-collect-garbage -d";

        # Check NixOS roots.
        "ncr" =
          "sudo -i nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/current-system|/run/booted-system|/proc|{memory|{censored)'";

      };

      interactiveShellInit = # bash
        ''

          # Rebuild NixOS from a flake.
          nrs () {
            sudo nixos-rebuild switch --flake ~/System/#$1
          }

          # Start a nix shell with specified packages and a nice prompt.
          pkgs () {
            nix-shell --command "PS1='\[\e[95;2m\][nix-shell]\[\e[0m\] $PS1'; return" -p "$@"
          }

          # Display disk usage information of directories.
          diskspace () {
            du -cha --max-depth=1 $1 2> /dev/null | sort -hr | head -n -1 | rg "^[\d\.]+[MG]" --color=never
          }

          # Return the absolute NixOS store path origin of the executable.
          where () {
            readlink -f $(which $1)
          }

          # Return the contents of the executable file.
          # Useful if executable is wrapped.
          inspect () {
            cat $(which $1)
          }

          # Look at a raw value and scale it continuously.
          # Interesting for looking at raw device sensors that need scaling.
          watch-sensor() {
            local file=$1
            local scale=''${2:-1}
            local prev=
            trap 'printf "\n"' EXIT
            while sleep 0.1; do
              local v scaled
              v=$(cat -- "$file") || continue
              scaled=$(awk -v v="$v" -v s="$scale" 'BEGIN{printf "%g", v*s}')
              if [ "$scaled" != "$prev" ]; then
                printf "\r\033[K%s" "$scaled"
                prev=$scaled
              fi
            done
          }

        '';

      # Set the bash prompt depending on the user and environment.
      promptInit = # bash
        ''
          if [[ $(whoami) == "root" ]]; then
            export PS1='\[\e[91m\]\u\[\e[2;3m\]@\h\[\e[0;1m\]:\[\e[96m\]\w\[\e[97m\]\$\[\e[0m\] '
          else
            export PS1='\[\e[92m\]\u\[\e[2;3m\]@\h\[\e[0;1m\]:\[\e[96m\]\w\[\e[97m\]\$\[\e[0m\] '
              fi
        '';

    };

  };
}
