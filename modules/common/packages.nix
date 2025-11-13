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
        toybox # Lightweight Unix utilities.
        mpv # Light weight media player.

      ];

    # Remove unused packages enabled my default.
    environment.defaultPackages = lib.mkForce [ ];
    services.speechd.enable = lib.mkForce false;
    programs.nano.enable = false;

    # Enable vim
    programs.vim.enable = true;

    # Disable documentation by default, for space saving.
    documentation.enable = config.modules.packages.manuals;

    # List of fonts.
    fonts.packages = with pkgs; [
      nerd-fonts.hack
    ];

  };

}
