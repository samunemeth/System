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

  # Custom plugins that are not in the plugin library.
  vim-checkstyle-integration = pkgs.vimUtils.buildVimPlugin {
    pname = "checkstyle-integration.nvim";
    version = "unstable-2026-04-25";
    src = pkgs.fetchFromGitHub {
      owner = "samunemeth";
      repo = "checkstyle-integration.nvim";
      rev = "548dc0285dff1d81a5cdf89380741fc2469e7a73";
      hash = "sha256-8Sy+qRxrHRdiGT+sQw1nKLhJYMB529uCaPBrN5cb/gM=";
    };
  };

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
      gitsigns-nvim # For visualising changes in files

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
    ++ lib.lists.optional languageTable.rust rustaceanvim
    ++ lib.lists.optionals languageTable.java [
      vim-checkstyle-integration
      nvim-jdtls
    ];

  # Create a derivation with the Neovim configuration files.
  neovim-home = pkgs.stdenvNoCC.mkDerivation {
    name = "neovim-home";
    src = ../../src/nvim;
    installPhase = ''
      # Copy contents to output.
      mkdir -p $out/nvim
      cp -r * $out/nvim/
    '';
  };

  # The packages that are required by Neovim.
  neovim-deps = with pkgs; [
    (python3.withPackages (p: [ p.pynvim ])) # For python provider.
    ripgrep # For live grep.
    fd # For quick file search.
    xclip # For using the system clipboard.
  ];

  # Wrap Neovim with a parametric configuration path.
  pathless-wrapped-neovim = config-path: pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {

    # Use the list of plugins defined above.
    inherit plugins;

    # Use the derivation as the configuration folder and add dependencies.
    wrapRc = false;
    wrapperArgs = "--set XDG_CONFIG_HOME ${config-path} --prefix PATH : ${lib.makeBinPath neovim-deps}";

    # Add aliases for vim and vi.
    vimAlias = true;
    viAlias = true;

    # Enable the python provider.
    withPython3 = true;

    # Disable extra providers.
    withNodeJs = false;
    withPerl = false;
    withRuby = false;

    # Disable Wayland support.
    waylandSupport = false;

  };

  wrapped-neovim = pathless-wrapped-neovim neovim-home;
  wrapped-neovim-dev = pkgs.writers.writeBashBin "nvim-dev" ''
    ${pathless-wrapped-neovim globals.dev-src-path}/bin/nvim "$@"
  '';

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

  config =
    lib.mkAlwaysThenIf config.modules.apps.neovim
      {
        modules.export-apps.neovim = wrapped-neovim;
      }
      {

        environment.systemPackages = [
          wrapped-neovim
          wrapped-neovim-dev
        ];

        # Set Neovim as the default editor.
        environment.sessionVariables.EDITOR = "nvim";

      };

}
