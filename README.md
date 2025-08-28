# NixOS Configuration

This is the central documentation and description for my NixOS configuration.

## Description

I am trying to achieve a minimal NixOS installation, with Qtile as my window
manager. For settings, I try to use Rofi menus where possible, as it provides
a clean, unified look, while remaining light-weight.

## ToDo

**General**

  - Add more documentation for initial setup.
  - Change Flameshot for Scrot?
  - Set up Veracrypt?

**Impérium**

  - Automatically initialize Seafile on system rebuild.

**Qtile**

  - Check if moving to Wayland would be beneficial?
    If not, delete configuration parts related to Wayland.
  - Create a visualization for Qtile key mapping?
  - Add more Qtile groups?

**Nvim**

  - Fix `lf` having back background.



## Setup

  - Clone this repository into the users home directory:
  ```
  cd ~
  git clone https://github.com/samunemeth/System.git
  ```
  - Generate an ssh key:
  ```
  ssh-keygen -t ed25519 -C "nemeth.samu.0202@gmail.com"
  ```
  - Configure Seafile:
  ```
  seaf-cli init -d /home/samu/.seafile-client
  mkdir /home/samu/Documents
  seaf-cli sync -l 411830eb-158e-4aa5-9333-869e7dfa7d99 -s https://seafile.samunemeth.hu -d /home/samu/Documents -u "nemeth.samu.0202@gmail.com"
  mkdir /home/samu/Notes
  seaf-cli sync -l 734b3f5b-7bd0-49c2-a1df-65f1cbb201a4 -s https://seafile.samunemeth.hu -d /home/samu/Notes -u "nemeth.samu.0202@gmail.com"
  ```

## Imperative Parts

There are some things that are still missing form the declarative configuration:

**Configuration Files**

  - `~/.config/nvim/spell/hu.utf-8.spl`

**Other Settings**

  - WiFi Networks
  - SSH Keys
  - Seafile Configuration
  - Firefox Bookmarks

*Everything else should be configured declaratively!*

