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
      xclip # Command line clipboard tool.

    ]
    ++ lib.lists.optionals config.modules.packages.lowPriority [

      treefmt # Recursive formatter for projects.
      stylua # Lua formatter.
      nixfmt-rfc-style # Nix formatter.
      beautysh # Bash formatter.

    ];

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    let
      hasLang = config.modules.programming;
    in
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

        plugins =
          with pkgs.vimPlugins;
          [

            # File management
            nvim-tree-lua # File tree
            plenary-nvim
            telescope-nvim # For quick file access

            # Visuals
            lightline-vim # Fancy status bar

            # Change tracking
            undotree # For an undo tree
            vim-fugitive # For git

            # Small improvements
            flash-nvim # For faster navigation with 'f'
            nvim-colorizer-lua # For visual color codes

            # LSP and syntax
            (nvim-treesitter.withPlugins (
              p:
              [
                # p.javascript
                # p.html
                # p.c
                p.lua
                p.vim
                p.vimdoc
                # p.query
                p.markdown
                p.markdown_inline
                p.nix
                p.yaml
                p.bash
              ]
              ++ lib.lists.optional hasLang.latex p.latex
              ++ lib.lists.optional hasLang.python p.python
              ++ lib.lists.optional hasLang.java p.java
              ++ lib.lists.optional hasLang.rust p.rust
            )) # Syntax highlighting
            conform-nvim # Formatting

          ]
          ++ lib.lists.optionals hasLang.latex [

            # LaTeX related
            vimtex # LaTeX language support
            knap # Live LaTeX and markdown compilation
            nabla-nvim # Equation previews
            ultisnips # For snippets mainly in LaTeX

          ]
          ++ lib.lists.optional hasLang.rust rustaceanvim;

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
