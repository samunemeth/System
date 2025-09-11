# --- Bash ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  programs.bash = {
  
    enable = true;
  
    # Aliases for editing and building NixOS.
    shellAliases = {
      "nec" = "( cd ~/System ; nvim flake.nix )";
      "nfu" = "( cd ~/System ; nix flake update )";
      "ncg" = "sudo nix-collect-garbage -d";
    };

    initExtra = ''
      nrs () {
        sudo nixos-rebuild switch --flake ~/System/#$1
      }
    '' + 

    # Custom bash prompt.
    ''
      export PS1='\[\e[92m\]\u\[\e[2;3m\]@\h\[\e[0;1m\]:\[\e[96m\]\w\[\e[39m\]\$\[\e[0m\] '
    '';

    # General aliases.
    shellAliases = {
      "snvim" = "sudo -E nvim";
      "l" = "ls -lhAG --color=always | sed -re 's/^[^ ]* //' | tail -n +2";
      "fetch" = "fastfetch";
    };
  

  };

  # User session variables, for ease of user.
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };

  };
}
