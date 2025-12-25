
# --- Qtile Keybindings Image Generator ---


# This script is a modified version of the `gen-keybinding-img` script provided
# by the official Qtile repository. You can find that script here:
# https://github.com/qtile/qtile/blob/master/scripts/gen-keybinding-img
# The licence of said project is provided here:

"""
Copyright (c) 2008-2025, the Qtile contributors. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""


# --- Libraries ---

from dataclasses import dataclass

# Library for rendering the image.
import cairocffi as cairo

# Part of Qtile for reading the configuration.
from libqtile.confreader import Config


# --- Settings ---

CONFIG_PATH = "apps/qtile/config.py"
OUTPUT_DIR = "assets/qtile-layout/"

SHOW_LEGEND = False
SHOW_MOUSE = False
SHOW_FN = False

HAS_STROKE = False
COLOR_STROKE = (.941, .965, .988)

COLOR_TEXT = (0, 0, 0)
# COLORA_BACKGROUND = (.051, .067, .09, 1)
COLORA_BACKGROUND = (0, 0, 0, 0)
COLOR_GENERIC = (.7, .7, .7)

COLOR_RED = (0.843, 0.372, 0.372)
COLOR_GREEN = (0.686, 0.686, 0)
COLOR_YELLOW = (1, 0.686, 0)
COLOR_CYAN = (0.513, 0.678, 0.678)
COLOR_VIOLET = (0.831, 0.521, 0.678)

# TODO: Make more inline constants settings or predefined constants.


# --- Constants ---

BUTTON_NAME_X = 10
BUTTON_NAME_Y = 60

COMMAND_X = 10
COMMAND_Y = 20

LEGEND = {
    "modifiers": COLOR_RED,
    "layout": COLOR_CYAN,
    "group": COLOR_GREEN,
    "window": COLOR_YELLOW,
    "other": COLOR_VIOLET,
}

SPECIAL_KEY_WIDTH = {
    "Backspace": 2,
    "Tab": 1.5,
    "\\": 1.5,
    "Return": 2.45,
    "shift": 2,
    "space": 5.5,
}

DICTIONARY = {
    "period": ",",
    "comma": ".",
    "Button1": "Left",
    "Button2": "Middle",
    "Button3": "Right",
    "modifiers": "mod",
    "mod4": "Meta",
    "mod1": "Alt",
    "control": "Ctrl",
    "shift": "Shift",
    "space": "Space",
    "Left": "←",
    "Down": "↓",
    "Right": "→",
    "Up": "↑",
    "AudioRaiseVolume": "Vol Up",
    "AudioLowerVolume": "Vol Down",
    "AudioMute": "Vol Mute",
    "AudioMicMute": "Mic Mute",
    "MonBrightnessUp": "Bright. Up",
    "MonBrightnessDown": "Bright. Down",
}

WIDTH = 78
HEIGHT = 70
GAP = 5

CHAR_LIMIT = 12  # This is for word warp.


# --- Everything Else ---

@dataclass
class Button:
    key: str
    x: int
    y: int
    width: int
    height: int


class ButtonArranger:

    def __init__(self, x: int, y: int):
        self.x = x
        self.y = y

        self.key_pos = {}
        self.start_x = x
        self.lines = 1

    def add(self, name: str) -> None:
        btn_width = SPECIAL_KEY_WIDTH[name] if name in SPECIAL_KEY_WIDTH else 1
        button = Button(name, self.x, self.y, btn_width * WIDTH, HEIGHT)
        self.x = self.x + GAP + btn_width * WIDTH
        self.key_pos[name] = button

    def skip(self, times: int = 1) -> None:
        self.x = self.x + GAP + times * WIDTH

    def newline(self) -> None:
        self.x = self.start_x
        self.y = self.y + GAP + HEIGHT
        self.lines += 1


# TODO: Add type hints from here down.
class KeyboardFactory:

    def __init__(self, modifiers, keys):
        self.modifiers = modifiers.split("-")
        self.keys = keys

        self.key_pos = {}
        self.lines = 0
        self.surface = None
        self.context = None

    def arrange(self):
        p = ButtonArranger(20, 20)

        for c in "`1234567890-=":
            p.add(c)
        p.add("Backspace")
        p.newline()

        p.add("Tab")
        for c in "qwertyuiop[]\\":
            p.add(c)
        p.newline()

        p.skip(1.6)
        for c in "asdfghjkl;'":
            p.add(c)
        p.add("Return")
        p.newline()

        p.add("shift")
        for c in "zxcvbnm":
            p.add(c)
        p.add("period")
        p.add("comma")
        p.add("/")
        p.skip(.98)
        p.add("Up")
        p.newline()

        p.add("control")
        p.skip(1)
        p.add("mod4")
        p.add("mod1")
        p.add("space")
        p.skip(2.8)
        p.add("Left")
        p.add("Down")
        p.add("Right")

        if SHOW_LEGEND or SHOW_MOUSE or SHOW_FN:
            p.newline()
            p.newline()

        if SHOW_FN:
            p.add("FN_KEYS")

        if (SHOW_LEGEND or SHOW_MOUSE) and SHOW_FN:
            p.newline()

        if SHOW_LEGEND:
            for legend in LEGEND.keys():
                p.add(legend)
            p.skip(2)

        if SHOW_MOUSE:
            p.add("Button1")
            p.add("Button2")
            p.add("Button3")

        # Save resulting variables.
        self.key_pos = p.key_pos
        self.lines = p.lines

    def render(self, filename):

        # Create a drawing surface of appropriate height.
        surface_height = self.lines * HEIGHT + (self.lines - 1) * GAP + 40
        self.surface = cairo.ImageSurface(
            cairo.FORMAT_ARGB32, 1280, surface_height)
        self.context = cairo.Context(self.surface)

        # Fill in the background.
        self.context.set_source_rgba(*COLORA_BACKGROUND)
        self.context.paint()

        # Draw regular keys.
        for b in self.key_pos.values():
            if b.key in ["FN_KEYS"]:
                continue
            self.draw_button(b.key, b.x, b.y, b.width, b.height)

        # Draw functional keys if needed.
        # TODO: Clean this block up.
        fn = (i for i in self.keys.values() if i.key[:4] == "XF86")
        if fn and SHOW_FN:
            fn_pos = self.key_pos["FN_KEYS"]
            x = fn_pos.x
            for i in fn:
                self.draw_button(i.key, x, fn_pos.y,
                                 fn_pos.width, fn_pos.height)
                x += GAP + WIDTH

        # Write to file with minimal metadata.
        self.surface.set_device_offset(0, 0)
        self.surface.set_mime_data("image/png", None)
        self.surface.write_to_png(filename)

    def draw_button(self, key, x, y, width, height):

        # Fill in the background of the key depending on the kind of key.
        self.context.rectangle(x, y, width, height)
        if key in LEGEND.keys():
            key_color = LEGEND[key]
        elif key in self.modifiers:
            key_color = LEGEND["modifiers"]
        elif key in self.keys:
            info = self.keys[key]
            color_index = info.scope if info.scope in [
                "group", "layout", "window"] else "other"
            key_color = LEGEND[color_index]
        else:
            key_color = COLOR_GENERIC
        self.context.set_source_rgb(*key_color)
        self.context.fill()

        # Show description of the key if needed.
        if key in self.keys:
            info = self.keys[key]
            self.show_multiline(x + COMMAND_X, y + COMMAND_Y, info)

        # Draw the outline of the key if needed.
        if HAS_STROKE:
            self.context.rectangle(x, y, width, height)
            self.context.set_source_rgb(*COLOR_STROKE)
            self.context.stroke()

        # Write the name of the button.
        if key[:4] == "XF86":
            key = key[4:]
            self.context.set_font_size(10)
        else:
            self.context.set_font_size(20)
        translation = DICTIONARY[key] if key in DICTIONARY else key

        self.context.set_source_rgb(*COLOR_TEXT)
        self.context.move_to(x + BUTTON_NAME_X, y + BUTTON_NAME_Y)
        self.context.show_text(translation)

    # Cairo doesn't support multi line text. Added with word wrapping.
    def show_multiline(self, x, y, key):
        char_limit = CHAR_LIMIT
        if key.key in SPECIAL_KEY_WIDTH:
            char_limit *= SPECIAL_KEY_WIDTH[key.key]

        self.context.set_font_size(10)
        self.context.set_source_rgb(*COLOR_TEXT)
        self.context.move_to(x, y)
        words = key.command.split(" ")
        words.reverse()
        printable = last_word = words.pop()
        while len(words):
            last_word = words.pop()
            if len(printable + " " + last_word) < char_limit:
                printable += " " + last_word
                continue

            self.context.show_text(printable)
            y += 10
            self.context.move_to(x, y)
            printable = last_word

        if last_word is not None:
            self.context.show_text(printable)


class KeyInfo:
    NAME_MAP = {
        "togroup": "to group",
        "toscreen": "to screen",
    }

    KEY_MAP = {
        "grave": "`",
        "semicolon": ";",
        "slash": "/",
        "backslash": "\\",
        "bracketleft": "[",
        "bracketright": "]",
        "quote": "'",
        "minus": "-",
        "equals": "=",
    }

    def __init__(self, key):
        if key.key in self.KEY_MAP:
            self.key = self.KEY_MAP[key.key]
        else:
            self.key = key.key
        self.command = self.get_command(key)
        self.scope = self.get_scope(key)

    def get_command(self, key):
        if hasattr(key, "desc") and key.desc:
            return key.desc

        cmd = key.commands[0]
        command = cmd.name
        if command in self.NAME_MAP:
            command = self.NAME_MAP[command]

        command = command.replace("_", " ")

        if len(cmd.args):
            if isinstance(cmd.args[0], str):
                command += " " + cmd.args[0]

        return command

    def get_scope(self, key):
        selectors = key.commands[0].selectors
        if len(selectors):
            return selectors[0][0]


class MouseInfo(KeyInfo):
    def __init__(self, mouse):
        self.key = mouse.button
        self.command = self.get_command(mouse)
        self.scope = self.get_scope(mouse)


# --- Main Function ---

def main():

    # Load the configuration file.
    c = Config(CONFIG_PATH)
    c.load()

    # Parse the configuration.
    kb_map = {}
    for key in c.keys:
        mod = "-".join(key.modifiers)
        if mod not in kb_map:
            kb_map[mod] = {}

        info = KeyInfo(key)
        kb_map[mod][info.key] = info

    for mouse in c.mouse:
        mod = "-".join(mouse.modifiers)
        if mod not in kb_map:
            kb_map[mod] = {}

        info = MouseInfo(mouse)
        kb_map[mod][info.key] = info

    # Loop through all the different modifier combinations.
    for modifier, keys in kb_map.items():

        # Calculate the output path.
        output_file = OUTPUT_DIR + (modifier or "no_modifier") + ".png"
        print(f"Generated image to: {output_file}")

        # Create a keyboard factory and generate the output image.
        factory = KeyboardFactory(modifier, keys)
        factory.arrange()
        factory.render(output_file)


if __name__ == "__main__":
    main()
