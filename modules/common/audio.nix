# --- Audio ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Enable sound with PulseAudio.
  services.pulseaudio.enable = if config.modules.gnome.enable then false else true;
  security.rtkit.enable = true;
  services.pipewire.enable = if config.modules.gnome.enable then true else false;

}
