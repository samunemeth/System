# --- Terminal File Manager ---

{ config, pkgs, lib, globals, ... }:
{

  
  environment.systemPackages = with pkgs; [
    highlight
    poppler-utils
  ];

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  # Configuration files from the web.
  home.file.".config/previewer.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/lf/previewer.sh";

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
    };
    settings = {
      "icons" = "true";
      "info" = "size";
      "ignorecase" = "true";
      "hiddenfiles" = ".*:desktop.ini:main.out:main.log:main.aux:main.synctex.gz:/home/${globals.user}/texmf";
      "previewer" = "~/.config/previewer.sh";
    };
    commands = {
      "type" = "%xdg-mime query filetype \"$f\"";
    };
  };

  # Add an lfcd command to change directories with the lf utility.
  programs.bash.initExtra = ''
    lfcd () {
      cd "$(command lf -print-last-dir "$@")"
    }
  '';

  # Icons have to be set manually for some reason.
  # A full example file can be found here:
  # https://github.com/gokcehan/lf/blob/master/etc/icons_colored.example
  home.file.".config/lf/icons".text = ''

    ln             # LINK
    or             # ORPHAN
    tw      t       # STICKY_OTHER_WRITABLE
    ow             # OTHER_WRITABLE
    st      t       # STICKY
    di             # DIR
    pi      p       # FIFO
    so      s       # SOCK
    bd      b       # BLK
    cd      c       # CHR
    su      u       # SETUID
    sg      g       # SETGID
    ex             # EXEC
    fi             # FILE
    
    *.tex               
    *.pdf                   00;38;2;179;11;0
    
    *.md                
    *.mdx               
    *.markdown          
    *.rmd               
    
    *.py                
    *.lua               
    
    *.gitconfig         
    *.gitignore         
    *.gitattributes     
    
    *.png               󰋩
    *.jpg               󰋩
    *.webp              󰋩

    *.mp4               
    *.mkv               

    *.mp3               
    *.wav               

  '';

  };
}
