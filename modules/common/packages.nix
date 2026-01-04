# --- Packages ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.packages.lowPriority = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        By default, there are some packages included that are not used that
        often, but are sometimes useful. Setting this to false will slightly
        reduce the size of the installation, but may cause inconveniences.
      '';
    };
    modules.packages.manuals = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Controls the presence of man pages.
      '';
    };
  };

  config = {

    # List of low priority packages.
    environment.systemPackages =
      with pkgs;
      lib.lists.optionals config.modules.packages.lowPriority [

        ripgrep # Recursive command line search command.
        fd # A user friendly file search engine.
        xclip # Command line clipboard tool.
        curl # Fetching form the web.
        btop # System monitoring and testing.
        fastfetchMinimal # Displaying system data.
        nix-tree # Explore sizes of packages.
        rsync # Powerful file copy tool.
        # ncdu # Folder size explorer.

      ]
      ++ lib.lists.optional (!config.modules.apps.ipycalc) calc;

    # Remove unused packages enabled my default.
    environment.defaultPackages = lib.mkForce [ ];
    services.speechd.enable = lib.mkForce false;
    programs.nano.enable = false;

    # Enable Vim if Neovim is not enabled. Set it as default editor weakly.
    programs.vim.enable = !config.modules.apps.neovim;
    environment.sessionVariables.EDITOR = lib.mkDefault "vim";

    # Set documentation availability in accordance with setting.
    documentation.enable = config.modules.packages.manuals;

    # List of fonts.
    fonts.packages = with pkgs; [
      nerd-fonts.hack
    ];

    # Enable fingerprint based authentication.
    # TODO: Make this an option, as it is not needed on all systems,
    # > or maybe not wanted for security reasons. No other config
    # > is needed other than this line.
    services.fprintd.enable = true;

  };

}
