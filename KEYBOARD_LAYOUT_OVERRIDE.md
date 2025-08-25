# Keyboard Layout Override Documentation

## Problem
The keyboard layout was hardcoded as "hu" (Hungarian) in `sulfur/modules/local.nix`, making it impossible to override this setting for different machines without modifying the module file itself.

## Solution
The keyboard layout settings in `local.nix` have been modified to use `lib.mkDefault`, which allows them to be overridden in `configuration.nix`.

### Changes Made

1. **In `sulfur/modules/local.nix`**:
   ```nix
   # Before:
   services.xserver.xkb = {
     layout = "hu";
     variant = "";
   };
   console.keyMap = "hu";

   # After:
   services.xserver.xkb = {
     layout = lib.mkDefault "hu";
     variant = lib.mkDefault "";
   };
   console.keyMap = lib.mkDefault "hu";
   ```

2. **In `sulfur/configuration.nix`**:
   Added an override section with commented examples:
   ```nix
   # --- Override Settings ---
   # Override keyboard layout from local.nix (change from "hu" to "us")
   # Uncomment the lines below to change keyboard layout to US:
   # services.xserver.xkb.layout = "us";
   # console.keyMap = "us";
   ```

## How to Use

To override the keyboard layout from Hungarian to US (or any other layout):

1. Edit `sulfur/configuration.nix`
2. Uncomment and modify the override lines:
   ```nix
   services.xserver.xkb.layout = "us";
   console.keyMap = "us";
   ```
3. Rebuild the system: `sudo nixos-rebuild switch`

## Benefits

- **Reusable modules**: The same `local.nix` module can be used across multiple systems
- **Machine-specific customization**: Each machine can override settings in its own `configuration.nix`
- **Default behavior preserved**: Without overrides, the system still defaults to Hungarian layout
- **Clean separation**: Module logic stays in modules, machine-specific config stays in `configuration.nix`

## How `lib.mkDefault` Works

In NixOS, when a configuration option is set multiple times:
1. Regular assignments override each other (last one wins)
2. `lib.mkDefault` assignments have lower priority than regular assignments
3. This allows modules to provide sensible defaults that can be easily overridden

Example priority (highest to lowest):
1. `option = value;` (regular assignment - highest priority)
2. `option = lib.mkOverride 500 value;` (custom priority)
3. `option = lib.mkDefault value;` (default - lowest priority)