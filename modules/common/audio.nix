# --- Audio ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Enable sound with Pulse Audio by default.
  services.pulseaudio.enable = true;
  services.pipewire.enable = false;
  security.rtkit.enable = true;

}
