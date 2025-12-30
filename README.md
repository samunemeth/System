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

  - [ ] *Set Up:* Make all apps use wrappers. [More Info](https://www.youtube.com/watch?v=Zzvn9uYjQJY)
  - [ ] *Look Into:* Wrapping Neovim. [More Info](https://ayats.org/blog/neovim-wrapper)
  - [ ] *Set Up:* hibernation with the new partition setup.
  - [ ] *Set Up:* Automatic locking, password prompt after hibernation.
  - [ ] *Look Into:* The *mini greeter* seems to act up on first boot.
        *Maybe just ditch the mini greeter?*
  - [ ] *Look Into:* Impermanence. [More Info](https://grahamc.com/blog/erase-your-darlings/)
        *Maybe just on the root at first, not home?*
  - [ ] *Look Into:* Automatic monitor detection, and saved layouts.
  - [ ] *Look Into:* What is actually good in Rofi? Remove some bloat from it?
  - [ ] *Fix:* There is no transparency possible in Zathura.
  - [ ] Sometimes there is a significant slowdown after the machine is powered
        on for a long time and/or had been sleeping for a long/multiple times.
  - [ ] *Set Up:* Installing to a virtual machine for testing.
        *This just needs to be cleanly merged.*
  - [ ] *Fix:* Clean up Python scripts.
  - [ ] *Look Into:* Markdown table formatter for Neovim.

**Documentation**

  - [ ] *Update:* Installation documentation.
  - [x] *Add:* Documentation for sops and sops-nix.

**Long Term**

  - [ ] *Look Into:* Creating a custom installation (and/or full system) ISO.
  - [ ] *Set Up:* A configuration for minimal installation.
  - [ ] *Set Up:* Gnome with declarative settings.
  - [ ] *Look Into:* Clean handling of missing utilities that are not present.
  - [ ] *Set Up:* Dev shells for different parts of development.

There are also small items marked with **TODO** inside comments. There are also
**NOTE**, **WARN** and **BUG** labels used.

# Qtile Keybindings

The images below are generated from the Qtile configuration with
[this script](actions/qtile-layout.py). There is a GutHub action set up that
regenerates the images if needed.

![Keybindings with Meta](/assets/qtile-layout/mod4.png)
![Keybindings with Meta and Shift](/assets/qtile-layout/mod4-shift.png)
![Keybindings with Meta and Control](/assets/qtile-layout/mod4-control.png)

# Language Support

The table below summarises the support for programming languages.
Syntax highlighting is handled by *tree-sitter*.
The language server and formatter is primarily designed to be used with *Neovim*.

| Language | Installed | Syntax | LSP | Formatter | Note
|----------|-----------|--------|-----|-----------|:-
| Markdown | ✓         | ✓      | -   | X         | *Pandoc* comes with *LaTeX*.
| Nix      | ✓         | ✓      | X   | ✓         | 
| Bash     | ✓         | ✓      | X   | ✓         |
| Lua      | ✓         | ✓      | X   | ✓         |
| Haskell  | ○         | ✓      | ✓   | ✓         |
| Java     | ○         | ✓      | -   | -         | 
| Julia    | ○         | ✓      | -   | -         | 
| LaTeX    | ○         | ✓      | -   | ✓         | 
| Python   | ○         | ✓      | ✓   | ✓         | I don't like the formatter.
| Rust     | ○         | ✓      | ✓   | ✓         |

|   | Description
|---|:-
| ✓ | Supported
| X | Not Supported but Planned
| - | No Planned Support / No possible support
| ○ | Enabled by Option

# Setup

> [!NOTE]
> For further guidance, look at the [official installation documentation](https://nixos.org/manual/nixos/stable/#sec-installation),
> the [NixOS wiki on Btrfs with encryption](https://nixos.wiki/wiki/Btrfs#Installation_with_encryption),
> and [this helpful video](https://www.youtube.com/watch?v=lUB2rwDUm5A).

> [!WARNING]
> There are missing steps in this guide at the moment, marked with "**MISSING STEPS**".


  - Get an install media to boot, then switch to the root user with:
    ```
    sudo -i
    ```
  - *If* you don't have a wired connection, connect to a WiFi network with the
    following commands:
    ```
    sudo systemctl start wpa_supplicant
    wpa_cli

    add_network
    set_network 0 ssid "<SSID>"
    set_network 0 psk "<PASSWORD>"
    enable_network 0

    quit
    ```
  - Do a network sanity check with `ping`:
    ```
    ping google.com
    ```
  - If you want some program to help you with the installation, you can install
    it now. `git` is needed, and I suggest using `lf` for easier file management,
    and `vim` for text editing, but the latter two is not necessary. Also select
    the editor of your choice for `lf`:
    ```
    nix-shell -p git lf vim <PACKAGES>
    export EDITOR=vim
    ```
  - Check disk and partition names, mount points with the first, and file system
    information with the second command at any time during the installation:
    ```
    lsblk
    lsblk -f
    ```
  - Create the needed partitions:
    ```
    cfdisk /dev/<OS-DISK>
    ```
    If asked, select `GPT` partition table.
    I recommend a boot partition between 512MiB and 1GiB, and a main partition
    of at least 8GiB, but preferable at least 16GiB.
    (A swap partition can also be created, but it is not
    mentioned in the rest of this guide.)
  - *If* you just created your boot partition, format it now:
    ```
    mkfs.fat -F 32 -n boot /dev/<BOOT-PART>
    ```
    *If* you already have one on your disk, it should work just fine as long
    as it **has enough space**. (Windows usually creates a really small boot
    partition, and resizing it is not the easiest or safest thing to do, so I
    recommend installing Linux before Windows for dual booting setups.)
  - Create a Luks encrypted Btrfs main partition:
    ```
    cryptsetup --verify-passphrase -v luksFormat /dev/<LINUX-PART>
    cryptsetup open /dev/<LINUX-PART> enc
    mkfs.btrfs /dev/mapper/enc
    ```
  - Create the needed sub volumes on the Btrfs partition:
    ```
    mount -t btrfs /dev/mapper/enc /mnt
    btrfs subvolume create /mnt/root /mnt/home /mnt/nix
    umount /mnt
    ```
  - Mount the Btrfs sub volumes to the appropriate places, with compression:
    ```
    mount -o subvol=root,compress=zstd /dev/mapper/enc /mnt 
    mkdir -p /mnt/{home,nix}
    mount -o subvol=home,compress=zstd /dev/mapper/enc /mnt/home
    mount -o subvol=nix,compress=zstd,noatime /dev/mapper/enc /mnt/nix
    ```
  - Mount the boot partition:
    ```
    mkdir -p /mnt/boot
    mount /dev/<BOOT-PART> /mnt/boot
    ```
  - Check mount points, and file systems now for good measure.
  - Clone this repository into the installers home directory, and change into it:
    ```
    cd ~
    git clone https://github.com/samunemeth/System.git
    cd System
    ```
    The following commands are all run from the working directory.
  - *If* your creating a new host, it is most easily done by coping an existing
    host's directory and adapting it:
    ```
    cp -r ~/System/hosts/<SOURCE-HOST> ~/System/hosts/<HOST>
    ```
    Otherwise, you can override an existing one if reinstalling.
  - Generate the hardware configuration for the system directly to the new host's
    directory:
    ```
    mv ~/System/hosts/<HOST>/hardware-configuration.nix hardware-configuration.nix.old
    nixos-generate-config --root /mnt --dir ~/System/hosts/<HOST>/
    ```
    **MISSING STEPS**
    *You need to add all the extra mount options, and file system support.*
  - You will have to add these changes in git:
    ```
    git add .
    ```
  - After all the changes are made and committed, you can finally install the
    system from the flake:
    ```
    nixos-install --flake ~/System#<HOST>
    ```
  - Get some host ssh keys for your machine. This can be done in two different
    ways:
    - Generate some **new** host ssh keys for your new machine:
      ```
      ssh-keygen -A -f /mnt
      ```
      In this case, the new keys need to be added to the `.sops.yaml` file,
      and the keys need to be updated. **MISSING STEPS**
    - Copy some existing keys from an external drive. **MISSING STEPS**
    - Make sure that the keys have the correct permissions:
      ```
      chmod 0400 /etc/ssh/ssh_host_*
      ```
  - As the changes are still not pushed to GitHub, you will need to move the
    current git repository to the new users home.
    Give the user ownership of the repository, and change remote URL:
    ```
    cp -r ~/System /mnt/home/<USER>/

    nixos-enter

    cd /home/<USER>
    chown -R <USER>:users System

    su <USER>
    cd ~/System
    git remote set-url origin git@github.com:samunemeth/System.git
    ```
  - Everything should be ready to use, you can boot into the installation.
    ```
    reboot
    ```
  - *If* the login screen does not work, you can switch to a virtual terminal by
    pressing `ctrl+shift+f2`, logging in and disabling the mini greeter with the
    following in your host's `configuration.nix`:
    ```nix
    services.xserver.displayManager.lightdm.greeters.mini.enable = lib.mkForce false;
    ```
  - *If* you have a fingerprint reader, enroll a fingerprint to your user:
    ```
    sudo fprintd-enroll $USER
    ```
  - Everything should be set! Rebuild with `nrs` and reboot to see if everything
    works as expected.


## Sops


To use sops encrypted secrets while rebuilding your machine, or editing the
secrets file, you will need an *age* key that is authorized in the `.sops.yaml`
file. You can either:
  - Use a *standalone age key* placed in the location `~/.config/sops/age/keys.txt`.
    This is practical when using a master key for a file, during installation
    or temporarily.
    Sops and sops-nix both automatically detect them.
  - Use an *age key derived from an SSH host key*.
    This way, your machine only
    needs it's host keys to persist. This is probably better for everyday use,
    as the host keys are owned by root, and therefore harder to 'peek' at.
    Sops-nix automatically derives the age keys from the host SSH keys, however
    sops needs them supplied directly. For this purpose, a `nes` shell function
    is provided for convenience.

Get an *age* **public** key of your machines host ssh key:
```bash
# With ssh-to-age installed:
sudo ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
# With ssh-to-age not installed yet:
nix-shell -p ssh-to-age --run 'sudo ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub'
```
This is useful when adding the key to `.sops.yaml` for example.

To get a **private** key, add the `-private-key` flag to the previous `ssh-to-age`
commands. Sops checks the `SOPS_AGE_KEY` environment variable for additional
or derived age keys to use for editing.
The following snippet adds a host ssh key derived age key to sops:
```bash
export SOPS_AGE_KEY=$(sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key)
```
This is the same snippet used in the `nes` shell function.

Note that you may need to prefix the paths in the snippets above with
`/mnt` if you are running them during the installation.
To update the `secrets.yaml` file with new keys or settings, use the
`updatekeys` option with the `sops` or `nes` commands.
SSH host keys can also be transferred, if the operating system needs to be
reinstalled. This way, there is no need to modify `.sops.yaml`.


## WiFi

Some WiFi networks are declared in the Nix configuration and `secrets.yaml` file.
To add a network, create and identifier for it, in this example, let that be `*WORK*.

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


## Fix for Missing Bootloader

Say that you accidentally deleted your boot partition, or the boot entries for
NixOS in your boot partition.

You could also perform other fixes, in a similar manner, for example a missing
root password for example. Of course, the disk has to be decrypted for it.

  - Boot a live medium that you would use for installing a new system.
  - Make sure you are running as root:
    ```bash
    sudo -i
    ```
  - Do the steps from the [setup](#Setup) guide for mounting all the partitions in the
    correct places.
  - Enter the mounted system:
    ```bash
    nixos-enter
    ```
  - Run the command for installing a bootloader for a new system:
    ```bash
    NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot --flake /home/<USER>/System#<HOST>
    ```
    The path to the flake is relative to the root of the machine entered, so the
    `/mnt` prefix needs to be omitted. Replace the path with the path to your
    flake.
  - Exit and reboot:
    ```bash
    exit
    reboot
    ```

*Based on the [NixOS wiki's bootloader page](https://nixos.wiki/wiki/Bootloader#From_an_installation_media).*


## Nvidia GPU

There are a plethora of versions for Nvidia drivers depending on the GPU type,
and they all take up a few GiB of space. When using a laptop that has a dual GPU
setup, there are different option for sharing the load, but in the end, using
only the integrated graphics might be beneficial for power usage while doing
everyday tasks. Power usage improved from 33W to 20W during video playback
when disabling the dedicated GPU, without a measurable loss in speed or quality.

If the offloading option was stricter,
such that would really only allows specific programs to use the dedicated GPU,
generally keep it more in a suspended state (now the dGPU wakes up
sometimes for no apparent reason), it would be probably better to use that
option, but in this state, it just increases power usage too much to be worth
keeping it on all the time. Using a specialization may be a good idea if the
dGPU is sometimes required.

I have tried investigating what is causing the dGPU wakeup, but have found to
definite answer. *Kmscon* definitely runs on the dGPU if available, but without
*Kmscon* wakeup still happen. Investigating this in detail would be a nice
side quest for the future.


Look at [modules/nvidia.template.nix](./modules/nvidia.template.nix) for information on the settings.
The template is based on the following sources:
  - [Community NixOS Wiki](https://nixos.wiki/wiki/Nvidia)
  - [Official NixOS Wiki](https://wiki.nixos.org/wiki/NVIDIA)


## Sticky Derivations

Sometimes stuff gets stuck in `/tmp`, and prevents packages from being garbage
collected. Just clear the `/tmp` directory and reboot:
```bash
sudo rm -rf /tmp/*
sudo reboot
```
*This should be solved later with impermanence.*


## Secure Boot

Using [Lanzaboote](https://github.com/nix-community/lanzaboote),
secure boot is possible with this configuration. There are general
[instructions for installation](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md),
that coves almost everything needed for installation. It is important that you
**cannot have Lanzaboote enabled for the first boot**. This means, that you have
to enable it later in the setup cycle. This is why it is not included in the
above setup instructions.

In addition, some extra information how to get secure boot keys enrolled on
machines that I used:

  - On my *HP ZBook*, secure boot setup mode is enabled while having
    *"Secure Boot"* disabled and after enabling *"Clear Secure Boot keys"*.
    After enrolling, secure boot is enabled automatically.


## Miscellaneous

Installing Windows after NixOS can cause the bootloader to become darker,
but this usually goes away after a few reboots. No idea what causes it.

On HP laptops the BIOS option *"Verify Boot Block on every boot"* causes issues,
as NixOS modifies the boot partition a lot.


# Resources

Here I have collected some useful resources I have used to create
this configuration.
For general linux questions, it is usually a good idea to consult the
[Arch Wiki](https://docs.qtile.org/en/stable/index.html).

## Options and Packages

For looking for packages or configuration options respectively.

  - [Nix Packages](https://search.nixos.org/packages) for looking up packages.
  - [MyNixOS](https://mynixos.com/) for looking up configuration options.
  - [Noogle](https://noogle.dev/) for looking up `pkgs` and `lib` functions.

## Nix Language

Wiki's for Nix language basics.

  - [Language Basics](https://nix.dev/tutorials/nix-language.html)
  - [Builtins](https://nix.dev/manual/nix/2.28/language/builtins.html)
  - [Nix Pills](https://nixos.org/guides/nix-pills/00-preface.html)

## Impermanence

  - [Blog Post](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)

## Hibernation

  - https://nixos.wiki/wiki/Hibernation
  - https://blog.tiserbox.com/posts/2025-03-10-enable-hibernation-on-nix-os.html
  - https://sawyershepherd.org/post/hibernating-to-an-encrypted-swapfile-on-btrfs-with-nixos/
  - https://discourse.nixos.org/t/btrfs-swap-not-enough-swap-space-for-hibernation/36805
  - https://github.com/NixOS/nixpkgs/issues/276374
  - https://haseebmajid.dev/posts/2024-07-30-how-i-setup-btrfs-and-luks-on-nixos-using-disko/

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
  - [Reference for Writers](https://nixos.wiki/wiki/Nix-writers)
  - [Using Wrappers](https://www.youtube.com/watch?v=Zzvn9uYjQJY)
  - [Wrapping Neovim](https://ayats.org/blog/neovim-wrapper)
  - [Erase Your Darlings](https://grahamc.com/blog/erase-your-darlings/)


