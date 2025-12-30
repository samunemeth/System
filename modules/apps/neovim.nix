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

      lua # Small, simple scripting language.
      stylua # Lua formatter.
      nixfmt-rfc-style # Nix formatter.
      beautysh # Bash formatter.

    ];

  # Update environment settings.
  environment = {

    # Set Neovim as the default editor.
    sessionVariables.EDITOR = "nvim";

    # Add alias for using Neovim with sudo.
    # NOTE: This should not be necessary if Neovim is custom wrapped.
    shellAliases = {
      "snvim" = "sudo -E nvim";
    };

  };

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    let
      hasLang = config.modules.code;
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
        # NOTE: This is probably not needed at all.
        defaultEditor = true;
        viAlias = false;
        vimAlias = false;

        plugins =
          with pkgs.vimPlugins;
          [

            # File management
            nvim-tree-lua # File tree
            telescope-nvim # For quick file access

            # Visuals
            lualine-nvim # Fancy status bar

            # Change tracking
            undotree # For an undo tree
            vim-fugitive # For git

            # Small improvements
            flash-nvim # For faster navigation with 'f'
            nvim-colorizer-lua # For visual color codes
            todo-comments-nvim # Special comment highlighting

            # LSP and syntax
            (nvim-treesitter.withPlugins (
              p:
              [
                p.vim
                p.vimdoc
                p.lua
                p.nix
                p.yaml
                p.markdown
                p.markdown_inline
                p.bash
              ]
              ++ lib.lists.optional hasLang.haskell p.haskell
              ++ lib.lists.optional hasLang.java p.java
              ++ lib.lists.optional hasLang.julia p.julia
              ++ lib.lists.optional hasLang.latex p.latex
              ++ lib.lists.optional hasLang.python p.python
              ++ lib.lists.optional hasLang.rust p.rust
            )) # Syntax highlighting
            conform-nvim # Formatting

          ]
          ++ lib.lists.optional hasLang.haskell haskell-tools-nvim
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

        # Neovim configuration files.
        ".config/nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/nvim";
          recursive = true;
        };

      };

    };
}
