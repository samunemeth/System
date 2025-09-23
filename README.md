<p align="center"> <picture>
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nixos.svg">
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nixos-white.svg">
  <img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nixos.svg" width="500px" alt="NixOS logo">
</picture> </p>

<p align="center"><i>My main flake and documentation for it.</i></p>


# Goal

I am trying to achieve a minimal NixOS installation for productivity.
I use Qtile as my window manager, Neovim for text and code editing,
Firefox for browsing and Lf for file management.
For settings, I try to use Rofi menus where possible.
I am mainly using these systems for internet browsing and LaTeX compilation.


# ToDo

**General**

  - [ ] *Look Into:* Why the *mini greeter* seems to act up on first boot.
  - [ ] *Look Into:* Separate Home Manager building for time saving.
  - [ ] *Set Up:* A script for enterprise WPA networks, or check why
    user interfaces do not work with it.
  - [ ] *Look Into:* Minimal plymouth themes.
  - [ ] *Set Up:* [sops-nix](https://github.com/Mic92/sops-nix) for secret management.
  - [ ] *Fix:* Alacritty not handling dynamic window titles.
    [More Info](https://github.com/alacritty/alacritty/issues/1636)
  - [ ] *Fix:* Firefox opening in the wrong group.
  - [x] *Fix:* Qtile machine dependent options.
  - [x] *Set Up:* Zip unpacking.
  - [ ] *Set Up:* Tar unpacking.
     

**Impérium**

  - [ ] *Set Up:* Automatically initialize Seafile on system rebuild.
  - [ ] *Look Into:* Adding even more declarative settings.
    [More Info](https://grahamc.com/blog/erase-your-darlings/)
  - [ ] *Look Into:* Adding even more preset Firefox options.

**Qtile**

  - [ ] *Look Into:* Creating a visualization for Qtile key mapping.
  - [ ] *Look Into:* More accurate battery remaining time calculation.
  - [x] *Set Up*: Use colors from flake.

**Nvim**

  - [ ] *Fix:* `lf` having black background.
  - [ ] *Set Up:* [TODO label highlights](https://github.com/folke/todo-comments.nvim).
  - [x] *Look Into:* why markdown indentation seems to be set incorrectly.

**Long Term**

  - [ ] *Look Into:* Creating a custom ISO.
  - [ ] *Set Up:* A configuration for minimal installation.


# Setup

> [!NOTE]
> For further guidance, look at the [official installation documentation](https://nixos.org/manual/nixos/stable/#sec-installation).


  - Get an install media to boot, then switch to the root user with:
    ```
    sudo -i
    ```
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
  - If you want some program to help you with the installation, you can install
    it now. I suggest using `lf` for easier file management, but it is not necessary:
    ```
    nix-shell -p lf <YOUR-PACKAGES>
    ```
  - **Create your partitions.**
  - **Format your partitions.**
  - **Mount your partitions.**
  - Clone this repository into the installers home directory, and change into it:
    ```
    cd ~
    git clone https://github.com/samunemeth/System.git
    cd System
    ```
  - Create a new host is most easily done by coping an existing host's
    directory and adapting it:
    ```
    cp -r ~/System/hosts/<SOURCE-HOST> ~/System/hosts/<YOUR-HOST>
    ```
  - Generate the hardware configuration for the system directly to the new host's
    directory:
    ```
    nixos-generate-config --root /mnt --dir ~/System/hosts/<YOUR-HOST>/
    ```
  - *You do not have to add anything to the `flake.nix` file
    as it scans the `hosts` directory automatically!*
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
    *You will be asked for a root password.*
  - As the changes are still not pushed to GitHub, you will need to move the
    current git repository to the new users home:
    ```
    cp -r ~/System /mnt/home/<YOUR-USER>/
    ```
  - Everything should be ready to use, you can boot into the installation.
    ```
    reboot
    ```
  - If the login screen does not work, you can
    switch to a console by pressing `ctrl+shift+f2`, logging in and disabling
    the greeter with the configuration suggested above.
    You can set up a network connection with the help of `nmtui` from the
    console if needed.
  - Get the ownership of the repository, as it was copied by a root user
    during installation.
    ```
    sudo chown -R <YOUR-USER>:users ~/System
    ```
  - Generate an ssh key:
    ```
    ssh-keygen -t ed25519 -C "nemeth.samu.0202@gmail.com"
    ```
  - Add your ssh key into your GitHub account, so you can push the new
    changes to your repository. This is needed as NixOS does not like dirty
    git trees. For this, you have
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
    boots if you disabled it before.

## Imperative Parts

There are some things that are still missing form the declarative configuration:

**Other Settings**

  - WiFi Networks
  - SSH Keys
  - Seafile Configuration
  - Account Logins

*Everything else should be configured declaratively!*

## WiFi

Setting up a WPA enterprise network does not work with `nmtui` or `networkmanager_dmenu` for some reason.
Here are some command for setting up such a network:

```
nmcli connection add type wifi con-name "<SSID>" ssid "<SSID>"
nmcli connection modify "<SSID>" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity "<IDENTITY>" 802-1x.password "<PASSWORD>"
nmcli connection up "<SSID>"
```

Replace `<SSID>`, `<IDENTITY>` and `<PASSWORD>` accordingly.


# Resources

Here I have collected some useful resources I have used to create
this configuration.

## Dual Booting

[Here](https://drakerossman.com/blog/how-to-dualboot-windows-and-nixos) is some
more information on dual booting NixOS.

## sops-nix

Some info on setting up with a Yubikey maybe?
  - [Reddit](https://www.reddit.com/r/NixOS/comments/1dbsx17/working_example_of_sopsnix_with_yubikey/)
  - [Reddit](https://www.reddit.com/r/NixOS/comments/1dbalru/comment/l802uqq/?context=3)
  - [Github](https://github.com/Mic92/sops-nix/issues/377#issuecomment-2926579189)

