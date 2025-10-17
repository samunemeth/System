# --- Neovim ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  environment.systemPackages =
    with pkgs;
    [

      tree-sitter # Neovim parser generator.
      ripgrep # Recursive command line search command.
      fd # A user friendly file search engine.
      gcc # C code compilation.
      nodejs_24 # Node.js distribution.
      xclip # Command line clipboard tool.

    ]
    ++ (
      if config.modules.packages.lowPriority then
        [

          treefmt # Recursive formatter for projects.
          stylua # Lua formatter.
          nixfmt-rfc-style # Nix formatter.

        ]
      else
        [ ]
    );

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      programs.neovim = {

        enable = true;

        # Set Neovim as default, but do not set aliases.
        defaultEditor = true;
        viAlias = false;
        vimAlias = false;

        plugins = with pkgs.vimPlugins; [

          # LaTeX related
          vimtex # LaTeX language support
          knap # Live LaTeX and markdown compilation
          nabla-nvim # Equation previews
          ultisnips # For snippets mainly in LaTeX

          # File management
          nvim-tree-lua # File tree
          plenary-nvim
          telescope-nvim # For quick file access

          # Visuals
          lightline-vim # Fancy status bar

          # Change tracking
          undotree # For an undo tree
          vim-fugitive # For git

          # LSP and syntax
          (nvim-treesitter.withPlugins (p: [
            p.javascript
            p.html
            p.c
            p.lua
            p.vim
            p.vimdoc
            p.query
            p.markdown
            p.markdown_inline
            p.nix
          ])) # Syntax highlighting
          conform-nvim # Formatting

        ];

      };

      # Configuration files from the web.
      home.file = {

        # Plug plugin manager for Neovim.
        # ".local/share/nvim/site/autoload/plug.vim" = {
        #   source = pkgs.fetchurl {
        #     url = "https://raw.githubusercontent.com/junegunn/vim-plug/refs/tags/0.14.0/plug.vim";
        #     hash = "sha256-ILTIlfmNE4SCBGmAaMTdAxcw1OfJxLYw1ic7m5r83Ns=";
        #   };
        # };

        # Neovim configuration files.
        ".config/nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/nvim";
          recursive = true;
        };

      };

    };
}
