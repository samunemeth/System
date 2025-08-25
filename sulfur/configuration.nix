

{ config, pkgs, lib, globals, ... }:
{
  imports = [

    # Results of hardware scan.
    ./hardware-configuration.nix

    # Custom modules containing configuration.
    ./modules/boot.nix
    ./modules/gui.nix
    ./modules/keyboard.nix
    ./modules/packages.nix
    ./modules/ssh.nix
    ./modules/audio.nix
    ./modules/files.nix

    # Program specific configurations.
    ./modules/neovim.nix
    ./modules/alacritty.nix
    ./modules/bash.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/rofi.nix
    ./modules/zathura.nix
    ./modules/qtile.nix
    ./modules/lf.nix

  ];


  # --- Flakes ---


  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # --- Networking ---


  # Just a basic host name.
  networking.hostName = "nixos";

  # Enable networking with network manager.
  networking.networkmanager.enable = true;

  # Enable the firewall, and do not let anything through.
  networking.firewall.enable = true;

  # Enable Bluetooth on the system.
  hardware.bluetooth.enable = true;


  # --- Locale ---


  # Set time zone to CET.
  time.timeZone = "Europe/Budapest";

  # Select the en_US locale, as this is the default,
  # and should be supported by all programs.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };



  # --- Misc ---

  
  # Disable sudo password prompt.
  security.sudo.wheelNeedsPassword = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;


  # --- Users ---


  # My default user.
  users.users.samu = {
    isNormalUser = true;
    description = "Samu Németh";
    extraGroups = [ "networkmanager" "wheel" "plugdev" "audio" ];
  };


  # --- Home Manager ---

  home-manager = {
    backupFileExtension = "hmbackup";
    useUserPackages = true;
  };

  home-manager.users.samu = {

    imports = [

      # As I am not running any gtk or qt applications at the moment,
      # there is no need for the themes.
      #./modules/home/theme.nix


    ];

    # --- State Version ---
    home.stateVersion = globals.stateVersion;

  };

  # --- State Version ---
  system.stateVersion = globals.stateVersion;

}
