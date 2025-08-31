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

  - Create a visualization for Qtile key mapping?
  - Add more Qtile groups?

**Nvim**

  - Fix `lf` having black background.

## Imperative Parts

There are some things that are still missing form the declarative configuration:

**Other Settings**

  - WiFi Networks
  - SSH Keys
  - Seafile Configuration
  - Account Logins

*Everything else should be configured declaratively!*


# Setup

> [!NOTE]
> For further guidance, look at the [official installation documentation](https://nixos.org/manual/nixos/stable/#sec-installation).


  - Get an install media to boot, then switch to the root user with:
    ```
    sudo -i
    ```
  - **Create your partitions.**
  - **Format your partitions.**
  - **Mount your partitions.**
  - If you are using a wired internet connection, you can skip the next step.
  - Connect to a WiFi network with these commands:
    ```
    sudo systemctl start wpa_supplicant
    wpa_cli

    add_network
    set_network 0 ssid "<YOUR-SSID>"
    set_network 0 psk "<YOUR-PASSWORD>"
    enable_network 0

    quit
    ```
  - Do a network sanity check with `ping`:
    ```
    ping google.com
    ```
  - Clone this repository into the installers home directory, and change into it:
    ```
    cd ~
    git clone https://github.com/samunemeth/System.git
    cd System
    ```
  - Generate the hardware configuration for the system:
    ```
    nixos-generate-config --root /mnt
    ```
  - Create a new folder if you are setting up a host (this is most easily
    done by coping an existing host and adapting it), or override one of the
    existing hosts hardware configuration if you are moving a system.
  - You do *not* have to add anything to the `flake.nix` file
    as it scans the `hosts` directory automatically!
  - Move the newly generated hardware configuration to your desired host's folder:
    ```
    cp -r /mnt/etc/nixos/hardware-configuration.nix ~/System/hosts/<YOUR-HOST>/
    ```
  - *Make sure that your hosts folder includes a `configuration.nix` file, as
    this is the entry point. Also make sure that this file imports
    `hardware-configuration.nix`, `overrides.nix` (if applicable) and other
    common and program specific modules that are intended to be used!*
    - As the *lightdm mini* greeter does not usually work for the initial login,
      you can disable it for the first few boot by adding the following
      configuration option to the `overrides.nix` file of your host:
      ```
      services.xserver.displayManager.lightdm.greeters.mini.enable = lib.mkForce false;
      ```
  - You will have to
    commit your changes, as nix does not like a dirty git tree. You will also
    need to set up your git identity temporarily:
    ```
    git config --global user.email "<YOUR-EMAIL>"
    git config --global user.name "<YOUR-NAME>"

    git add .
    git commit -m "Added changes to accomodate new host."
    ```
  - After all the changes are made and committed, you can finally install the
    system from the flake:
    ```
    nixos-install --flake .#<YOUR-HOST>
    ```
  - Please remember to set passwords for users that do not have them configured
    declaratively!
  - As the changes are still not pushed to GitHub, you will need to move the
    current git repository to the new users home:
    ```
    cp -r ~/System /mnt/home/<YOUR-USER>/
    ```
  - Everything should be ready to use, you can boot into the installation.
    ```
    reboot
    ```
  - The login screen does not work, you can
    switch to a console by pressing `ctrl+shift+f2`, logging in and disabling
    the greeter with the configuration suggested above.
    - You can set up a network connection with the help of `nmtui` from the
      console.
  - Generate an ssh key:
    ```
    ssh-keygen -t ed25519 -C "nemeth.samu.0202@gmail.com"
    ```
  - Get the ownership of the repository, as it was copied by a root user:
    ```
    sudo chown -R <YOUR-USER>:users ~/System
    ```
  - Add your ssh key into your GitHub account, so you can push the new
    `hardware-configuration.nix` file to your repository. For this, you have
    to change the origin URL of the repository:
    ```
    cd ~/System
    git remote set-url origin git@github.com:samunemeth/System.git
    git push
    ```
  - For system rebuilds to work correctly, you need to at least initialize Seafile.
    The sync configurations are not strictly required in the beginning.
    ```
    mkdir /home/samu/.seafile-client
    seaf-cli init -d /home/samu/.seafile-client

    mkdir /home/samu/Documents
    seaf-cli sync -l 411830eb-158e-4aa5-9333-869e7dfa7d99 -s https://seafile.samunemeth.hu -d /home/samu/Documents -u "nemeth.samu.0202@gmail.com"

    mkdir /home/samu/Notes
    seaf-cli sync -l 734b3f5b-7bd0-49c2-a1df-65f1cbb201a4 -s https://seafile.samunemeth.hu -d /home/samu/Notes -u "nemeth.samu.0202@gmail.com"
    ```
  - Everything should be set! Rebuild with `nrs` and reboot to see if everything
    works as expected. Enable the *lightdm mini* greeter after the first few
    boots.



