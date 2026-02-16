# --- ISO Configuration ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # Set the languages that should have syntax highlighting.
  languageList = [
    "lua"
    "nix"
    "bash"
    "python"
  ];
  grammars = p: builtins.map (x: p.${x}) (lib.remove "lua" languageList);

  # The list of plugins to use with Neovim.
  plugins = with pkgs.vimPlugins; [

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

  ];

  # Create a derivation with the Neovim configuration files.
  neovim-home = pkgs.stdenvNoCC.mkDerivation {
    name = "neovim-home";
    src = ../src/nvim;
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
  ];

  # Wrap Neovim.
  wrapped-neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {

    # Use the list of plugins defined above.
    inherit plugins;

    # Use the derivation as the configuration folder and add dependencies.
    wrapRc = false;
    wrapperArgs = "--set XDG_CONFIG_HOME ${neovim-home} --prefix PATH : ${lib.makeBinPath neovim-deps}";

    # Do not aliases for vim and vi.
    # Thing might not work out, we need Vim as a fallback.
    vimAlias = false;
    viAlias = false;

    # Disable extra providers.
    withNodeJs = false;
    withPerl = false;
    withRuby = false;

    # Disable Wayland support.
    waylandSupport = false;

  };

  wrapped-lf = pkgs.symlinkJoin {
    name = "wrapped-lf";
    buildInputs = [ pkgs.makeWrapper ];
    paths = with pkgs; [

      lf # Core.

      fd # For recursive funding of files and directories.
      fzf # For fuzzy finding.

      zip # Creating zip files.
      unzip # Unpacking zip files.

    ];
    postBuild =
      let
        lfhome = pkgs.stdenvNoCC.mkDerivation {
          name = "lfhome";
          src = ../src/lf;
          installPhase = ''
            # Remove the previewer script.
            rm ./previewer.sh
            # Copy contents to output.
            mkdir -p $out/lf
            cp -r * $out/lf/
          '';
        };
      in
      ''
        wrapProgram $out/bin/lf \
          --set LF_CONFIG_HOME ${lfhome}
      '';
  };

in
{

  imports = [

    ../modules/common/locale.nix

  ];

  # Add some packages that might be required for installation.
  environment.systemPackages = with pkgs; [

    # Some wrapped applications.
    wrapped-neovim
    wrapped-lf

    # For faster finding.
    ripgrep
    fd

    # For some system info.
    lm_sensors
    fastfetchMinimal
    btop
    nix-tree

    # All of the packages below should be there by default.
    util-linux
    cryptsetup
    btrfs-progs
    curl

  ];
  programs.git.enable = true;

  # Set Neovim as the default editor.
  environment.sessionVariables.EDITOR = "nvim";

  # Remove some bloat.
  environment.defaultPackages = lib.mkForce [ ];
  services.speechd.enable = lib.mkForce false;
  programs.nano.enable = false;
  programs.vim.enable = false;

  # Enable networking with network manager.
  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [ ];
  };

  # Enable flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Reduce the compression a bit so it becomes faster.
  isoImage.squashfsCompression = "zstd -Xcompression-level 5";

  # Add some message on login.
  programs.bash.interactiveShellInit = ''
    fastfetch
  '';

}
