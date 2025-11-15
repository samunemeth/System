# --- Nvidia Driver Template ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{


  # GPU testing software, may use a lot of space.
  #environment.systemPackages = with pkgs; [
  #
  #  furmark # For stress testing graphics cards.
  #  nvtopPackages.nvidia # For inspecting usage and processes.
  #  powertop # for inspecting power usage in detail.
  #
  #];

  # NOTE: Based on the following sources:
  # > https://nixos.wiki/wiki/Nvidia
  # > https://wiki.nixos.org/wiki/NVIDIA

  # WARN: Kmscon may mess with GPU sleeping?

  # Enable OpenGL and Vulkan.
  hardware.graphics.enable = true;

  # Load Nvidia driver for X11.
  services.xserver.videoDrivers = [
    "amdgpu" # AMD integrated graphics.
    #"modesetting" # Intel integrated graphics.
    #"nvidia" # Removing this removes all Nvidia drivers.
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = false;

    # NOTE: List of supported graphics cards for open drivers:
    # > https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # > Older graphics cards may require a different driver version.
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # --- Dual GPU Laptops ---

    # Nvidia power management. I do not think it makes a big difference.
    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {

      # PCI bus ids for specific hardware configuration.
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:198:0:0";
      #intelBusId = "PCI:0:2:0";

      # This mode relies more on the dedicated GPU, but uses more power.
      #sync.enable = true;

      # This mode uses the integrated graphics by default, and enables
      # offloading of applications to the dedicated GPU with a command.
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

    };

  };

}
