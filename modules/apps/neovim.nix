# --- Neovim ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # Gather the enabled coding languages, and the grammars that are needed.
  languageTable = config.modules.code;
  languageList = lib.attrNames (lib.filterAttrs (n: v: v) languageTable);
  grammars = p: builtins.map (x: p.${x}) (lib.remove "lua" languageList);

  # The list of plugins to use with Neovim.
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
      (nvim-treesitter.withPlugins grammars) # Syntax highlighting
      conform-nvim # Formatting

    ]
    ++ lib.lists.optional languageTable.haskell haskell-tools-nvim
    ++ lib.lists.optionals languageTable.latex [

      # LaTeX related
      vimtex # LaTeX language support
      knap # Live LaTeX and markdown compilation
      nabla-nvim # Equation previews
      ultisnips # For snippets mainly in LaTeX

    ]
    ++ lib.lists.optional languageTable.rust rustaceanvim;

  # Create a derivation with the Neovim configuration files.
  neovim-home = pkgs.stdenv.mkDerivation {
    name = "neovim-home";
    src = ../../apps/nvim;
    installPhase = ''
      # Copy contents to output.
      mkdir -p $out/nvim
      cp -r * $out/nvim/
    '';
  };

  # The packages that are required by Neovim.
  neovim-deps = with pkgs; [
    ripgrep # For live grep.
    fd # For quick file search.
    xclip # For using the system clipboard.
  ];

  # Wrap Neovim.
  wrapped-neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {

    # Use the list of plugins defined above.
    inherit plugins;

    # Use the derivation as the configuration folder and add dependencies.
    wrapRc = false;
    wrapperArgs = "--set XDG_CONFIG_HOME ${neovim-home} --prefix PATH : ${lib.makeBinPath neovim-deps}";

    # Add aliases for vim and vi.
    vimAlias = true;
    viAlias = true;

    # Disable extra providers.
    withNodeJs = false;
    withPerl = false;
    withRuby = false;

    # Disable Wayland support.
    waylandSupport = false;

  };

in
{

  options.modules = {
    apps.neovim = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the Neovim text editor.
        Removed Vim, and sets Neovim as the default editor.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.neovim {

    environment.systemPackages = [ wrapped-neovim ];

    # Set Neovim as the default editor.
    environment.sessionVariables.EDITOR = "nvim";

  };

}
