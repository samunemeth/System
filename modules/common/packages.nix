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
  };

  config = {

    # List of packages.
    environment.systemPackages =
      with pkgs;
      [

        vim # Simple text editor.

      ]
      ++ (
        if config.modules.packages.lowPriority then
          [

            curl # Fetching form the web.
            btop # System monitoring and testing.
            fastfetchMinimal # Displaying system data.
            nix-tree # Explore sizes of packages.

          ]
        else
          [ ]
      );

    # Remove unused packages enabled my default.
    environment.defaultPackages = lib.mkForce [ ];
    services.speechd.enable = lib.mkForce false;
    programs.nano.enable = false;

    # Disable documentation by default, for space saving.
    documentation.enable = lib.mkDefault false;

    # List of fonts.
    fonts.packages = with pkgs; [
      nerd-fonts.hack
    ];

  };

}
