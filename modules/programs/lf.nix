# --- Terminal File Manager ---

{ config, pkgs, lib, globals, ... }:
{

  # Packages for previewing files.  
  environment.systemPackages = with pkgs; [
    highlight
    poppler-utils
    exiftool
    zip                  # For creating zip files.
    unzip                # For unpacking zip files.
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
      "zz" = "zip";
    };
    settings = {
      "icons" = "true";
      "info" = "size";
      "ignorecase" = "true";
      "hiddenfiles" = ".*:desktop.ini:main.out:main.log:main.aux:main.synctex.gz:/home/${globals.user}/texmf:lost+found";
      "previewer" = "~/.config/lf/previewer.sh";
      "filesep" = ";";
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

      # Override the default open command to be able to implement unzipping.
      "open" = ''
        &{{
          filetype=$(xdg-mime query filetype "$f")
          if [[ $filetype == "application/zip" ]] then
            todir="''${f%.*}-unzip/"
            mkdir -p "$todir"
            unzip "$f" -d "$todir"
            printf "Unzipped contents."
          elif [[ $filetype == "application/pdf" ]] then
            zathura "$f" --fork -l error
            printf "Opened with Zathura."
          else
            alacritty -e $EDITOR "$f"
            printf "Unknown filetype, opened with text editor."
          fi
        }}
      '';

      # Zip selected files into one zip file.
      "zip" = ''
        %{{
          printf "ZIP file name [NewZip.zip]: "
          read name
          name=''${name:-NewZip.zip}
          IFS=';' read -ra filesarray <<< "$fx"
          filelist=""
          for absfile in "''${filesarray[@]}"; do
            relfile=''${absfile##"$PWD"/}
            filelist="$filelist $relfile"
          done 
          zip -r "$PWD/$name" $filelist
          printf "Zipped selection."
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
