# --- Terminal File Manager ---

{ config, pkgs, lib, globals, ... }:
{

  # Packages for previewing files.  
  environment.systemPackages = with pkgs; [
    # highlight
    # poppler-utils
    # exiftool
  ];

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  # Configuration files.
  home.file = {
    ".config/lf/icons".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/lf/icons";
    ".config/lf/previewer.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/lf/previewer.sh";
  };

  # Enables lf and defines some basic settings.
  programs.lf = {
    enable = true;
    keybindings = {
      "<enter>" = "open";
      "<esc>" = "quit";
      "." = "set hidden!";
      "gd" = "cd ~/Documents";
      "gn" = "cd ~/Notes";
      "gc" = "cd ~/.config";
      "DD" = "delete";
      "a" = "add";
    };
    settings = {
      "icons" = "true";
      "info" = "size";
      "ignorecase" = "true";
      "hiddenfiles" = ".*:desktop.ini:main.out:main.log:main.aux:main.synctex.gz:/home/${globals.user}/texmf:lost+found";
      "previewer" = "~/.config/lf/previewer.sh";
    };
    commands = {
      "type" = "%xdg-mime query filetype \"$f\"";
      "add" = ''
        %{{
          printf "New: "
          read ans
          if [[ $ans == */ ]]; then
            mkdir -p $ans
          elif [[ $ans == */* ]]; then
            mkdir -p ''${ans%/*}
            touch $ans
          else
            touch $ans
          fi
        }}
      '';
    };
  };

  # Add an lfcd command to change directories with the lf utility.
  programs.bash.initExtra = ''
    lfcd () {
      cd "$(command lf -print-last-dir "$@")"
    }
  '';


  };
}
