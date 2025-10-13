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

  - [x] *Set Up:* [sops-nix](https://github.com/Mic92/sops-nix) for secret management.
  - [x] *Set Up:* Separate VSCode configuration form Java.
  - [x] *Look Into:* Cleaner module organization.
  - [x] *Set Up:* Low Priority packages.
  - [x] *Set Up:* Some declarative WiFi networks with sops.
        [More Info](https://www.reddit.com/r/NixOS/comments/zneyil/using_sopsnix_to_amange_wireless_secrets/)
  - [x] *Set Up:* A script for enterprise WPA networks, or check why
        user interfaces do not work with it.
  - [ ] *Set Up:* Host keys on other machines.
  - [ ] *Fix:* The *mini greeter* seems to act up on first boot.
  - [ ] *Fix:* Alacritty not handling dynamic window titles.
        [More Info](https://github.com/alacritty/alacritty/issues/1636)
  - [ ] *Fix:* Firefox opening in the wrong group.
  - [ ] *Set Up:* Tar unpacking.
  - [ ] *Set Up:* Trashcan in Lf.
  - [ ] *Set Up:* Openers in Lf.
  - [ ] *Set Up:* Password prompt after hibernation.

**Declarative Wonderland**

  - [ ] *Set Up:* Automatically initialize Seafile on system rebuild.
  - [ ] *Set Up:* Declarative user ssh keys.
  - [ ] *Look Into:* Impermanence. [More Info](https://grahamc.com/blog/erase-your-darlings/)
  - [ ] *Look Into:* Adding even more preset Firefox options.

**Qtile**

  - [x] *Set Up:* Machine specific options with nix options.
  - [x] *Look Into:* Automatically determining network devices.
  - [x] *Set Up:* Only use key available in 34 key layout.
  - [x] *Look Into:* Creating a visualization for Qtile key mapping.
    *Not worth it!*
  - [x] *Look Into:* More accurate battery remaining time calculation.
    *Pretty accurate after all...*
  - [ ] *Validate:* That automatic settings based on `/sys` are working.

**Nvim**

  - [x] *Set Up:* Keybindings for VSCode
  - [x] *Set Up:* Automatic formatting with [conform.nvim](https://github.com/stevearc/conform.nvim).
  - [x] *Set Up:* Automatically decrypt `secrets.yaml` if key is available.
    *Not implemented as it messes with the file diff and just overrides everything,
    although correct, not pretty or git-friendly.*

**Documentation**

  - [ ] *Update:* Installation documentation.
  - [ ] *Add:* Documentation for sops and sops-nix.

**Long Term**

  - [ ] *Look Into:* Creating a custom ISO.
  - [ ] *Set Up:* A configuration for minimal installation.
  - [ ] *Set Up:* Gnome with declarative settings.


# Setup

> [!NOTE]
> For further guidance, look at the [official installation documentation](https://nixos.org/manual/nixos/stable/#sec-installation).

> [!WARNING]
> This is pretty outdated at this point.


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
    this is the entry point. Also make sure that this file enables settings 
    that make other common and program specific modules available!*
  - You will have to
    commit your changes, as nix does not like a dirty git tree. You will also
    need to set up your git identity temporarily:
    ```
    git config --global user.email "<YOUR-EMAIL>"
    git config --global user.name "<YOUR-NAME>"

    git add .
    git commit -m "Added changes to accomodate new host."
    ```
    *MAYBE JUST ADD?*
  - After all the changes are made and committed, you can finally install the
    system from the flake:
    ```
    nixos-install --flake .#<YOUR-HOST>
    ```
    *NEED HOST SSH KEYS?*
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
    switch to a virtual terminal by pressing `ctrl+shift+f2`, logging in and disabling
    the greeter with the configuration suggested above.
    You can set up a network connection with the help of `nmtui` from the
    console if needed.
    *IS DISABLING REQUIRED OR JUST LOGIN?*
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
    works as expected.


## Sops

Get an *age* public key of your machines host ssh key:
```bash
nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```


## WiFi

Some WiFi networks are declared in the Nix configuration and `secrets.yaml` file.
To add a network, create and identifier for it, in this example, let that be `WORK`.

**If *WORK* is a regular network:**

Then add it to the `normal_networks` list in the `networks.yaml` file, than append
the following to the `wireless-env` key in the `secrets.yaml` file:
```
    WORK_SSID=<SSID>
    WORK_MGMT=<MGMT-METHOD>
    WORK_PASS=<PASSWORD>
```
Replace `<SSID>`, `<MGMT-METHOD>` and `<PASSWORD>` accordingly.
Where `<MGMT-METHOD>` is usually either `wpa-psk` or `sae`. You can find out the 
exact value by saving the network imperatively and looking at the generated configuration.

**If *WORK* is an enterprise network:**

Then add it to the `normal_networks` list in the `networks.yaml` file, than append
the following to the `wireless-env` key in the `secrets.yaml` file:
```
    WORK_SSID=<SSID>
    WORK_IDEN=<USERNAME>
    WORK_PASS=<PASSWORD>
```
Replace `<SSID>`, `<USERNAME>` and `<PASSWORD>` accordingly.

Setting up a WPA enterprise network imperatively does not work with `nmtui`
or `networkmanager_dmenu` for some reason.
Here are some command for setting up such a network:
```bash
nmcli connection add type wifi con-name "<SSID>" ssid "<SSID>"
nmcli connection modify "<SSID>" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity "<IDENTITY>" 802-1x.password "<PASSWORD>"
nmcli connection up "<SSID>"
```
Replace `<SSID>`, `<IDENTITY>` and `<PASSWORD>` accordingly.

To list all the connections saved, and their configuration file location, use
the following command:
```bash
sudo nmcli -f NAME,DEVICE,FILENAME connection show
```

To generate Nix snippets from your saved networks, check out
[this tool](https://github.com/janik-haag/nm2nix).


# Imperative Parts

There are some things that are still missing form the declarative configuration:

  - SSH keys.
  - Seafile configuration.
  - Some parts of Firefox.
  - Basically VSCode as a whole.
  - Gnome.
  - Account Logins (Firefox, Google, VSCode, GitHub)

*Everything else should be configured declaratively!*


# Resources

Here I have collected some useful resources I have used to create
this configuration.
For general linux questions, it is usually a good idea to consult the
[Arch Wiki](https://docs.qtile.org/en/stable/index.html).

## Options and Packages

For looking for packages or configuration options respectively.

  - [Nix Packages](https://search.nixos.org/packages) for looking up packages.
  - [MyNixOS](https://mynixos.com/) for looking up configuration options.

## Nix Language

Wiki's for Nix language basics.

  - [Language Basics](https://nix.dev/tutorials/nix-language.html)
  - [Builtin](https://nix.dev/manual/nix/2.28/language/builtins.html)

## Firefox

Resources for configuring Firefox with Nix.

  - [View Current Policies: `about:policies#documentation`](about:policies#documentation)
  - [Available Policies](https://mozilla.github.io/policy-templates/#preferences)
  - [Available Preferences](https://searchfox.org/firefox-main/source/modules/libpref/init/StaticPrefList.yaml)
  - [Some Examples](https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/7)
  - [Declarative Bookmarks](https://discourse.nixos.org/t/firefox-import-html-bookmark-file-in-a-declarative-manner/38168/23)

## Other

Guides, threads, wiki's that I have found useful.

  - [Hibernation](https://nixos.wiki/wiki/Hibernation)
  - [Bluetooth](https://wiki.nixos.org/wiki/Bluetooth)
  - [Some Dudes Configuration](https://github.com/nmasur/dotfiles/tree/b282e76be4606d9f2fecc06d2dc8e58d5e3514be)
  - [Declarative WiFi with Sops](https://www.reddit.com/r/NixOS/comments/zneyil/using_sopsnix_to_amange_wireless_secrets/)
  - [How to Dual Boot Windows and NixOS](https://drakerossman.com/blog/how-to-dualboot-windows-and-nixos)
  - [YubiKeys on NixOS](https://youtu.be/3CeXbONjIgE)

