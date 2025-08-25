# --- Audio ---

{ config, pkgs, lib, globals, ... }:
{

  # Enable sound with PulseAudio.
  services.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire.enable = false;

}
