# --- Bash ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  programs.bash = {
  
    enable = true;
  
    # Shell aliases for shorter commands.
    shellAliases = {
  
      # Aliases for editing and building NixOS.
      "nec" = "( cd ~/System ; nvim flake.nix )";
      "nrs" = "sudo nixos-rebuild switch --flake ~/System/#sulfur";
      "nfu" = "( cd ~/System ; nix flake update )";
      "ncg" = "sudo nix-collect-garbage -d";
  
      # More general aliases.
      "snvim" = "sudo -E nvim";
      "l" = "ls -lhAG --color=always | sed -re 's/^[^ ]* //' | tail -n +2";
  
    };
  
    # Setting custom bash prompt.
    initExtra = ''
      export PS1='\[\e[92m\]\u\[\e[2;3m\]@\h\[\e[0;1m\]:\[\e[96m\]\w\[\e[39m\]\$\[\e[0m\] '


      lfcd () {
        cd "$(command lf -print-last-dir "$@")"
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
