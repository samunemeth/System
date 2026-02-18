# --- Nvidia Driver Template ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Based on the following sources:
  # https://nixos.wiki/wiki/Nvidia
  # https://wiki.nixos.org/wiki/NVIDIA

  # GPU testing software, may use a lot of space.
  environment.systemPackages = with pkgs; [

    # For stress testing graphics cards. Unfree package.
    # Use the following command to start the application:
    # $ FurMark_GUI
    furmark

    # For inspecting usage and processes.
    # As this information is reported on the software link level, running
    # `nvtop` keeps the dGPU awake.
    nvtopPackages.nvidia

    # For inspecting power usage in detail. Not the fastest piece of software,
    # for a matter of fact, it is laggy as hell.
    powertop

  ];

  # Kmscon may mess with GPU sleeping.

  # Enable OpenGL and Vulkan.
  # Some Vulkan packages may need separate importing?
  # I have not confirmed this.
  hardware.graphics.enable = true;

  # Load Nvidia driver for X11.
  services.xserver.videoDrivers = [
    "amdgpu" # AMD integrated graphics.
    #"modesetting" # Intel integrated graphics. WTF, why?
    #"nvidia" # Removing this removes all Nvidia drivers.
  ];

  hardware.nvidia = {
    modesetting.enable = true; # Some kernel magic I guess.
    nvidiaSettings = false; # Disable the settings app, there is no need for it.

    # List of supported graphics cards for open drivers:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Older graphics cards may require a different driver version.
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # --- Dual GPU Laptops ---

    # Nvidia power management. I do not think it makes a big difference.
    # Fine-grained is only available if using offloading.
    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {

      # PCI bus ids for specific hardware configuration.
      # There is a convoluted process for getting there, that involves
      # converting from hex to decimal LOL.
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:198:0:0";
      #intelBusId = "PCI:0:2:0";

      # This mode relies more on the dedicated GPU, but uses more power.
      # I have not confirmed the difference this makes in practice.
      # The dGPU still seems to go to sleep sometimes, and wake up randomly.
      #sync.enable = true;

      # This mode uses the integrated graphics by default, and enables
      # offloading of applications to the dedicated GPU with a command.
      # Applications may call for use of the dGPU without using the offloading
      # command, for example Furmark. (Furmark also does not even need the
      # drivers; I am unsure how that is possible.)
      # Applications may disregard the offloading command, for example, I have
      # not managed to get Firefox working with it for example.
      # I think there are only slight differences in these settings.
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

    };

  };

}
