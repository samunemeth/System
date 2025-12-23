#######################################
#  Qtile keybindings image generator  #
#######################################

# Ran with:
# ./gen-keybinding-img -o /home/samu/System/assets/qtile-layout/ -c /home/samu/System/apps/qtile/config.py

import os
import sys

import cairocffi as cairo
from cairocffi import ImageSurface

from libqtile.confreader import Config

BUTTON_NAME_Y = 65
BUTTON_NAME_X = 10

COMMAND_Y = 20
COMMAND_X = 10

LEGEND = ["modifiers", "layout", "group", "window", "other"]

CUSTOM_KEYS = {
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

# --- STYLE SETTINGS ---

HAS_STROKE = False

SHOW_LEGEND = False
SHOW_MOUSE = False
SHOW_FN = False

COLOR_STROKE = (.941, .965, .988)
COLOR_TEXT = (0, 0, 0)
# COLORA_BACKGROUND = (.051, .067, .09, 1)
COLORA_BACKGROUND = (0, 0, 0, 0)
COLOR_GENERIC = (.7, .7, .7)

# ---

lines = 1

class Button:
    def __init__(self, key, x, y, width, height):
        self.key = key
        self.x = x
        self.y = y
        self.width = width
        self.height = height


class Pos:
    def __init__(self, x, y):
        self.x = x
        self.row_x = x
        self.y = y
        self.custom_width = {}
        global lines
        lines = 1
        for i, val in CUSTOM_KEYS.items():
            self.custom_width[i] = val * WIDTH

    def get_pos(self, name):
        if name in self.custom_width:
            width = self.custom_width[name]
        else:
            width = WIDTH

        info = Button(name, self.x, self.y, width, HEIGHT)

        self.x = self.x + GAP + width

        return info

    def skip_x(self, times=1):
        self.x = self.x + GAP + times * WIDTH

    def next_row(self):
        self.x = self.row_x
        self.y = self.y + GAP + HEIGHT
        global lines
        lines += 1


class KeyboardPNGFactory:
    def __init__(self, modifiers, keys):
        self.keys = keys
        self.modifiers = modifiers.split("-")
        self.key_pos = self.calculate_pos(20, 20)

    def rgb_red(self, context):
        context.set_source_rgb(0.8431372549, 0.3725490196, 0.3725490196)

    def rgb_green(self, context):
        context.set_source_rgb(0.6862745098, 0.6862745098, 0)

    def rgb_yellow(self, context):
        context.set_source_rgb(1, 0.6862745098, 0)

    def rgb_cyan(self, context):
        context.set_source_rgb(0.5137254902, 0.6784313725, 0.6784313725)

    def rgb_violet(self, context):
        context.set_source_rgb(0.831372549, 0.5215686275, 0.6784313725)

    def calculate_pos(self, x, y):
        pos = Pos(x, y)

        key_pos = {}
        for c in "`1234567890-=":
            key_pos[c] = pos.get_pos(c)

        key_pos["Backspace"] = pos.get_pos("Backspace")
        pos.next_row()

        key_pos["Tab"] = pos.get_pos("Tab")
        for c in "qwertyuiop[]\\":
            key_pos[c] = pos.get_pos(c)
        pos.next_row()

        pos.skip_x(1.6)
        for c in "asdfghjkl;'":
            key_pos[c] = pos.get_pos(c)
        key_pos["Return"] = pos.get_pos("Return")
        pos.next_row()

        key_pos["shift"] = pos.get_pos("shift")
        for c in "zxcvbnm":
            key_pos[c] = pos.get_pos(c)
        key_pos["period"] = pos.get_pos("period")
        key_pos["comma"] = pos.get_pos("comma")
        key_pos["/"] = pos.get_pos("/")
        pos.skip_x(.98)
        key_pos["Up"] = pos.get_pos("Up")
        pos.next_row()

        key_pos["control"] = pos.get_pos("control")
        pos.skip_x()
        key_pos["mod4"] = pos.get_pos("mod4")
        key_pos["mod1"] = pos.get_pos("mod1")
        key_pos["space"] = pos.get_pos("space")
        pos.skip_x(2.8)
        key_pos["Left"] = pos.get_pos("Left")
        key_pos["Down"] = pos.get_pos("Down")
        key_pos["Right"] = pos.get_pos("Right")

        if SHOW_LEGEND or SHOW_MOUSE or SHOW_FN:
            pos.next_row()
            pos.next_row()

        if SHOW_FN:
            key_pos["FN_KEYS"] = pos.get_pos("FN_KEYS")

        if (SHOW_LEGEND or SHOW_MOUSE) and SHOW_FN:
            pos.next_row()

        if SHOW_LEGEND:
            for legend in LEGEND:
                key_pos[legend] = pos.get_pos(legend)
            pos.skip_x(2)

        if SHOW_MOUSE:
            key_pos["Button1"] = pos.get_pos("Button1")
            key_pos["Button2"] = pos.get_pos("Button2")
            key_pos["Button3"] = pos.get_pos("Button3")

        return key_pos
    
    def render(self, filename):
        surface_height = lines * HEIGHT + (lines - 1) * GAP + 40
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
                self.rgb_red(context)
            elif key == "group":
                self.rgb_green(context)
            elif key == "layout":
                self.rgb_cyan(context)
            elif key == "window":
                self.rgb_yellow(context)
            else:
                self.rgb_violet(context)
            context.rectangle(x, y, width, height)
            context.fill()

        elif key in self.modifiers:
            context.rectangle(x, y, width, height)
            self.rgb_red(context)
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
        c_width = 12
        if key.key in CUSTOM_KEYS:
            c_width *= CUSTOM_KEYS[key.key]

        context.set_font_size(10)
        context.set_source_rgb(*COLOR_TEXT)
        context.move_to(x, y)
        words = key.command.split(" ")
        words.reverse()
        printable = last_word = words.pop()
        while len(words):
            last_word = words.pop()
            if len(printable + " " + last_word) < c_width:
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
            self.rgb_green(context)
        elif key.scope == "layout":
            self.rgb_cyan(context)
        elif key.scope == "window":
            self.rgb_yellow(context)
        else:
            self.rgb_violet(context)

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


def get_kb_map(config_path=None):

    c = Config(config_path)
    if config_path:
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

def main():
    config_path = "apps/qtile/config.py"
    output_dir = "assets/qtile-layout/"

    kb_map = get_kb_map(config_path)
    for modifier, keys in kb_map.items():
        if not modifier:
            filename = "no_modifier.png"
        else:
            filename = f"{modifier}.png"

        output_file = output_dir + filename
        f = KeyboardPNGFactory(modifier, keys)
        print(f"New file here: {output_file}")
        f.render(output_file)

if __name__ == "__main__":
    main()

