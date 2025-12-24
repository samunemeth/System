
# --- Qtile Keybindings Image Generator ---


# This script is a modified version of the `gen-keybinding-img` script provided
# by the official Qtile repository. You can find that script here:
# https://github.com/qtile/qtile/blob/master/scripts/gen-keybinding-img
# The licence of said project is provided here:

# > Copyright (c) 2008-2025, the Qtile contributors. All rights reserved.
# > 
# > Permission is hereby granted, free of charge, to any person obtaining a copy
# > of this software and associated documentation files (the "Software"), to deal
# > in the Software without restriction, including without limitation the rights
# > to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# > copies of the Software, and to permit persons to whom the Software is
# > furnished to do so, subject to the following conditions:
# > 
# > The above copyright notice and this permission notice shall be included in
# > all copies or substantial portions of the Software.
# > 
# > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# > IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# > FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# > AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# > LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# > OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# > SOFTWARE.


# --- Libraries ---

from dataclasses import dataclass

# Library for rendering the image.
import cairocffi as cairo
from cairocffi import ImageSurface

# Part of Qtile for reading the configuration.
from libqtile.confreader import Config


# --- Constants ---


BUTTON_NAME_X = 10
BUTTON_NAME_Y = 65

COMMAND_X = 10
COMMAND_Y = 20

LEGEND = ["modifiers", "layout", "group", "window", "other"]

SPECIAL_KEY_WIDTH = {
    "Backspace": 2,
    "Tab": 1.5,
    "\\": 1.5,
    "Return": 2.45,
    "shift": 2,
    "space": 5.5,
}

WIDTH = 78
HEIGHT = 70
GAP = 5

CHAR_LIMIT = 12 # This is for word warp.

# --- Settings ---


CONFIG_PATH = "apps/qtile/config.py"
OUTPUT_DIR = "assets/qtile-layout/"


SHOW_LEGEND = False
SHOW_MOUSE = False
SHOW_FN = False

HAS_STROKE = False
COLOR_STROKE = (.941, .965, .988)

COLOR_TEXT = (0, 0, 0)
#COLORA_BACKGROUND = (.051, .067, .09, 1) # This is the GitHub dark background.
COLORA_BACKGROUND = (0, 0, 0, 0)
COLOR_GENERIC = (.7, .7, .7)

COLOR_RED = (0.843, 0.372, 0.372)
COLOR_GREEN = (0.686, 0.686, 0)
COLOR_YELLOW = (1, 0.686, 0)
COLOR_CYAN = (0.513, 0.678, 0.678)
COLOR_VIOLET = (0.831, 0.521, 0.678)


# --- Everything Else ---


@dataclass
class Button:
    key: str
    x: int
    y: int
    width: int
    height: int


class ButtonArranger:

    def __init__(self, x, y):
        self.x = x
        self.start_x = x
        self.y = y
        self.lines = 1

    def add(self, name):
        button_width = (SPECIAL_KEY_WIDTH[name] * WIDTH) if name in SPECIAL_KEY_WIDTH else WIDTH
        button = Button(name, self.x, self.y, button_width, HEIGHT)
        self.x = self.x + GAP + button_width
        return button

    def skip(self, times=1):
        self.x = self.x + GAP + times * WIDTH

    def newline(self):
        self.x = self.start_x
        self.y = self.y + GAP + HEIGHT
        self.lines += 1


class KeyboardPNGFactory:

    def __init__(self, modifiers, keys):
        self.keys = keys
        self.modifiers = modifiers.split("-")

        self.p = ButtonArranger(20, 20)
        self.place_keys()


    def place(self, name):
        self.key_pos[name] = self.p.add(name)

    def place_keys(self):
        self.key_pos = {}

        for c in "`1234567890-=":
            self.place(c)
        self.place("Backspace")
        self.p.newline()

        self.place("Tab")
        for c in "qwertyuiop[]\\":
            self.place(c)
        self.p.newline()

        self.p.skip(1.6)
        for c in "asdfghjkl;'":
            self.place(c)
        self.place("Return")
        self.p.newline()

        self.place("shift")
        for c in "zxcvbnm":
            self.place(c)
        self.place("period")
        self.place("comma")
        self.place("/")
        self.p.skip(.98)
        self.place("Up")
        self.p.newline()

        self.place("control")
        self.p.skip(1)
        self.place("mod4")
        self.place("mod1")
        self.place("space")
        self.p.skip(2.8)
        self.place("Left")
        self.place("Down")
        self.place("Right")

        if SHOW_LEGEND or SHOW_MOUSE or SHOW_FN:
            self.p.newline()
            self.p.newline()

        if SHOW_FN:
            self.place("FN_KEYS")

        if (SHOW_LEGEND or SHOW_MOUSE) and SHOW_FN:
            self.p.newline()

        if SHOW_LEGEND:
            for legend in LEGEND:
                self.place(legend)
            self.p.skip(2)

        if SHOW_MOUSE:
            self.place("Button1")
            self.place("Button2")
            self.place("Button3")
    
    def render(self, filename):
        surface_height = self.p.lines * HEIGHT + (self.p.lines - 1) * GAP + 40
        surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, 1280, surface_height)
        context = cairo.Context(surface)
        with context:
            context.set_source_rgba(*COLORA_BACKGROUND)
            context.paint()

        for i in self.key_pos.values():
            if i.key in ["FN_KEYS"]:
                continue

            self.draw_button(context, i.key, i.x, i.y, i.width, i.height)

        # draw functional
        fn = [i for i in self.keys.values() if i.key[:4] == "XF86"]
        if len(fn) and SHOW_FN:
            fn_pos = self.key_pos["FN_KEYS"]
            x = fn_pos.x
            for i in fn:
                self.draw_button(context, i.key, x, fn_pos.y, fn_pos.width, fn_pos.height)
                x += GAP + WIDTH
        surface.set_device_offset(0, 0)
        surface.set_mime_data("image/png", None)
        surface.write_to_png(filename)

    def draw_button(self, context, key, x, y, width, height):
        fn = False
        if key[:4] == "XF86":
            fn = True

        if key in LEGEND:
            if key == "modifiers":
                context.set_source_rgb(*COLOR_RED)
            elif key == "group":
                context.set_source_rgb(*COLOR_GREEN)
            elif key == "layout":
                context.set_source_rgb(*COLOR_CYAN)
            elif key == "window":
                context.set_source_rgb(*COLOR_YELLOW)
            else:
                context.set_source_rgb(*COLOR_VIOLET)
            context.rectangle(x, y, width, height)
            context.fill()

        elif key in self.modifiers:
            context.rectangle(x, y, width, height)
            context.set_source_rgb(*COLOR_RED)
            context.fill()

        elif key in self.keys:
            k = self.keys[key]
            context.rectangle(x, y, width, height)
            self.set_key_color(context, k)
            context.fill()

            self.show_multiline(context, x + COMMAND_X, y + COMMAND_Y, k)

        else:
            context.rectangle(x, y, width, height)
            context.set_source_rgb(*COLOR_GENERIC)
            context.fill()

        if HAS_STROKE:
            context.rectangle(x, y, width, height)
            context.set_source_rgb(*COLOR_STROKE)
            context.stroke()

        context.set_source_rgb(*COLOR_TEXT)
        if fn:
            key = key[4:]
            context.set_font_size(10)
        else:
            context.set_font_size(14)

        context.move_to(x + BUTTON_NAME_X, y + BUTTON_NAME_Y)
        context.show_text(self.translate(key))

    def show_multiline(self, context, x, y, key):
        """Cairo doesn't support multiline. Added with word wrapping."""
        char_limit = CHAR_LIMIT
        if key.key in SPECIAL_KEY_WIDTH:
            char_limit *= SPECIAL_KEY_WIDTH[key.key]

        context.set_font_size(10)
        context.set_source_rgb(*COLOR_TEXT)
        context.move_to(x, y)
        words = key.command.split(" ")
        words.reverse()
        printable = last_word = words.pop()
        while len(words):
            last_word = words.pop()
            if len(printable + " " + last_word) < char_limit:
                printable += " " + last_word
                continue

            context.show_text(printable)
            y += 10
            context.move_to(x, y)
            printable = last_word

        if last_word is not None:
            context.show_text(printable)

    def set_key_color(self, context, key):
        if key.scope == "group":
            context.set_source_rgb(*COLOR_GREEN)
        elif key.scope == "layout":
            context.set_source_rgb(*COLOR_CYAN)
        elif key.scope == "window":
            context.set_source_rgb(*COLOR_YELLOW)
        else:
            context.set_source_rgb(*COLOR_VIOLET)

    def translate(self, text):
        dictionary = {
            "period": ",",
            "comma": ".",
            "Button1": "Left",
            "Button2": "Middle",
            "Button3": "Right",
            "modifiers": "mod",
            "mod4": "Meta",
            "mod1": "Alt",
            "control": "Control",
            "shift": "Shift",
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

        if text not in dictionary:
            return text

        return dictionary[text]


class KInfo:
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


class MInfo(KInfo):
    def __init__(self, mouse):
        self.key = mouse.button
        self.command = self.get_command(mouse)
        self.scope = self.get_scope(mouse)


def get_kb_map():

    c = Config(CONFIG_PATH)
    c.load()

    kb_map = {}
    for key in c.keys:
        mod = "-".join(key.modifiers)
        if mod not in kb_map:
            kb_map[mod] = {}

        info = KInfo(key)
        kb_map[mod][info.key] = info

    for mouse in c.mouse:
        mod = "-".join(mouse.modifiers)
        if mod not in kb_map:
            kb_map[mod] = {}

        info = MInfo(mouse)
        kb_map[mod][info.key] = info

    return kb_map


# --- Main Function ---


def main():

    # Get the keyboard map from the configuration file.
    kb_map = get_kb_map()

    # Loop through all the different modifier combinations.
    for modifier, keys in kb_map.items():

        # Create and object with the appropriate data.
        f = KeyboardPNGFactory(modifier, keys)

        output_file = OUTPUT_DIR + (modifier or "no_modifier") + ".png"
        print(f"Generated image to: {output_file}")
        f.render(output_file)

if __name__ == "__main__":
    main()

