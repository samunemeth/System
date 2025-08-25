# --- lf: Terminal File Manager ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

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
