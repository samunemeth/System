# Neovim Configuration

This repository is for managing my Neovim configuration.
This includes:

  - `init.lua` configuration and settings.
  - `UltiSnips` snippets.
  - Custom words added to the spell checker.

## Installation steps:

  - Install the latest version of Neovim:
    [Installation guide for Neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package)
  - Clone this repository into the configuration directory
  (`~/.config/nvim` on linux)
  - Install python3 if not yet installed:<br>
    `sudo apt install python3`
  - Install the python provider for Neovim:<br>
    `python3 -m pip install --user --upgrade --break-system-packages pynvim`
  - Install plug for Neovim:
    [Installation guide for Plug](https://github.com/junegunn/vim-plug?tab=readme-ov-file#neovim)
  - In Neovim run `:PlugInstall` to install all the plugins specified
  - To install missing spell files:
      - Run Neovim with `nvim -u NONE`, this disables all plugins.
      - Ignore the error that pops up
      - Run `:set spell spelllang=en,hu`
      (you can add additional language packages you want to install)
      - You might get a message saying the install failed, ignore that too.
  - Other packages may be required for plugins! Install them accordingly.
