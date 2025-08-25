# --- Neovim ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  programs.neovim = {

    enable = true;

    # Set Neovim as default, but do not set aliases.
    defaultEditor = true;
    viAlias = false;
    vimAlias = false;

  };


  # Configuration files from the web.
  home.file = {
    
    # Plug plugin manager for Neovim.
    ".local/share/nvim/site/autoload/plug.vim" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/junegunn/vim-plug/refs/tags/0.14.0/plug.vim";
        hash = "sha256-ILTIlfmNE4SCBGmAaMTdAxcw1OfJxLYw1ic7m5r83Ns=";
      };
    };

    # Neovim configuration files.
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/nvim";
      recursive = true;
    };

    # LaTeX outline files.
    "texmf/tex/latex" = {
      source = pkgs.fetchFromGitHub {
        owner = "samunemeth";
        repo = "latex-outlines";
        rev = "5d1c9d3e276a7c1c988065afb9dd09a2e66a3789"; # Updated 2025-08-15
        hash = "sha256-QjQHDao0wyBic8cTehCCjUtYTEqSKcaQzAgMUOT2g20=";
      };
      recursive = true;
    };

  };

  # Run a script on activation that installs the packages and file parsers.
  # TODO: See if this is running as root, and ruining package access rights?
  home.activation.install-nvim = 
    let nvimPath = with pkgs; lib.makeBinPath [ neovim git gcc ]; in
    lib.hm.dag.entryAfter ["installPackages"] ''
      export PATH=${nvimPath}:$PATH
      run nvim --headless +PlugInstall +TSUpdate +qa 
    '';

  };
}
