# --- Imports ---

import os
import sys

import subprocess
import importlib.util

from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.widget import base


# --- Machine Specific ---

spec = importlib.util.spec_from_file_location("qtilemachine", os.path.expanduser("~/.config/qtilemachine.py"))
qtilemachine = importlib.util.module_from_spec(spec)
sys.modules["qtilemachine"] = qtilemachine
spec.loader.exec_module(qtilemachine)


# --- Colors ---

spec = importlib.util.spec_from_file_location("qtilecolor", os.path.expanduser("~/.config/qtilecolor.py"))
qtilecolor = importlib.util.module_from_spec(spec)
sys.modules["qtilecolor"] = qtilecolor
spec.loader.exec_module(qtilecolor)


# --- Global Settings ---

mod = "mod4"
terminal = guess_terminal()
qtile_home_path = os.path.expanduser("~/.config/qtile")



# --- Startup Script ---

@hook.subscribe.startup
def autostart():

    # Get the absolute path of the startup script.
    script = os.path.expanduser("~/.config/qtile/autostart.sh")

    # Get the coordinates of the center of the main screen.
    xc = str(screens[0].x + screens[0].width // 2)
    yc = str(screens[0].y + screens[0].height // 2)

    # Run the startup script with the parameters.
    subprocess.Popen([script, qtilecolor.background_main, xc, yc])


# --- Keyboard Shortcuts ---

keys = [

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Focus Left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus Right"),
    Key([mod], "j", lazy.layout.down(), desc="Focus Down"),
    Key([mod], "k", lazy.layout.up(), desc="Focus Up"),
    Key([mod], "space", lazy.layout.next(), desc="Move Focus"),

    # Move Windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move Left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Moveto Right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move Down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move Up"),

    # Grow windows.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow Left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow Right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow Down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow Up"),

    # Layout management.
    Key([mod], "t", lazy.next_layout(), desc="Toggle Layouts"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Fullscreen"),

    Key([mod], "v", lazy.window.kill(), desc="Kill Window"),

    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload Config"),

    # Application quick launch
    Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "b", lazy.spawn("firefox"), desc="Firefox"),

    # Rofi menu options
    Key([mod], "d", lazy.spawn("rofi -show drun")),
    Key([mod], "s", lazy.spawn(f"rofi -show power-menu -modi \"power-menu:{qtile_home_path}/rofi/rofi-power-plugin --choices shutdown/reboot/suspend/hibernate/logout\"")),
    Key([mod], "c", lazy.spawn("rofi -show calc -modi calc")),
    Key([mod], "w", lazy.spawn("networkmanager_dmenu")),
    Key([mod], "e", lazy.spawn(f"{qtile_home_path}/rofi/rofi-bluetooth-contained")),
    Key([mod], "x", lazy.spawn(f"rofi -show rofi-sound -modi \"rofi-sound:{qtile_home_path}/rofi/rofi-sound-plugin\"")),

    # Hide and show bottom bar.
    Key([mod], "Tab", lazy.hide_show_bar(), desc="Hide/Show Bar"),

    # Hardware key maps to commands.
    Key([], "XF86MonBrightnessUp", lazy.spawn("sudo xbacklight -inc 5")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("sudo xbacklight -dec 5")),

    Key([], "XF86AudioRaiseVolume", lazy.spawn("pulseaudio-ctl up")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pulseaudio-ctl down")),
    Key([], "XF86AudioMute", lazy.spawn("pulseaudio-ctl mute")),

    Key([], "XF86AudioMicMute", lazy.spawn("pulseaudio-ctl mute-input")),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),

    Key([], "XF86Calculator", lazy.spawn("rofi -show calc -modi calc")),

    # Keyboard layout switching.
    # This is practical to have it bound to 'a', as 'a' is placed in the same
    # spot on QWERTY and Dvorak respectively.
    Key([mod], "a", lazy.widget["keyboardlayout"].next_keyboard()),

    # Screenshot.
    Key([mod, "shift"], "s", lazy.spawn("scrot ~/Downloads/%b%d::%H%M%S.png", shell=True)),
    Key([], "Print", lazy.spawn("scrot ~/Downloads/%b%d::%H%M%S.png", shell=True)),

]

for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

groups = [
    Group("U", spawn="alacritty"),
    Group("I"),
    Group("O"),
    Group("P", spawn="firefox"),
    Group("["),
    Group("N"),
    Group("M"),
    Group(","),
    Group("."),
    Group("/"),
]

group_key_lookup = {
    "U": "U",
    "I": "I",
    "O": "O",
    "P": "P",
    "[": "bracketleft",
    "N": "N",
    "M": "M",
    ",": "comma",
    ".": "period",
    "/": "slash",
}

for i in groups:
    keys.extend(
        [
            Key(
                [mod],
                group_key_lookup[i.name],
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            Key(
                [mod, "shift"],
                group_key_lookup[i.name],
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
        ]
    )

layouts = [
    layout.Columns(
        border_width=2,
        border_focus=qtilecolor.foreground_soft,
        border_normal=qtilecolor.background_contrast,
    ),
    layout.Max(),
]

# --- Widget settings ---

widget_defaults = dict(
    font="Hack Nerd Font",
    fontsize=14,
    padding=3,
)
extension_defaults = widget_defaults.copy()

# This is a utility function for shortening window names.
def shorten_widow_title(text):

    # Firefox uses an unfriendly em dash instead of a simple dash.
    for string in [" — Mozilla Firefox"]:
        text = text.replace(string, "")

    return text


# --- Widgets ---

widgets = [
    widget.GroupBox(
        this_current_screen_border = qtilecolor.foreground_main,
        this_screen_border = qtilecolor.foreground_main,
        borderwidth = 2,
        disable_drag = True,
    ),
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70,
    ),
    widget.KeyboardLayout(
        configured_keyboards = qtilemachine.available_layouts,
        display_map = {
            "hu": "HU",
            "us": "US",
            "us dvp": "DV",
            "us intl": "IN",
        },
        padding = 10,
    ),
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),

    # --------------------------

    # widget.OpenWeather(
    #     # cityid = 3052009,
    #     cityid = 2750821,
    #     hide_crach = True,
    #     format = "{location_city}: {main_temp:.0f}°{units_temperature} {weather}",
    # ),

    # widget.WindowName(
    #     parse_text = shorten_widow_title,
    #     padding = 10,
    # ),

    # --------------------------

    widget.Spacer(),

    # --------------------------

    # widget.Sep(
    #     linewidth = 2,
    #     padding = 10,
    #     size_percent = 70
    # ),


    # --------------------------

    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70,
    ),
    widget.Bluetooth(
        default_show_battery = True,
        hide_unnamed_devices = True,
        symbol_connected = "",
        symbol_paired = "󰂯",
        default_text = "󰂯 {num_connected_devices}",
        device_format = "D: {name}{battery_level} {symbol}",
        adapter_format = "A: {name} ({powered}{discovery})",
        device_battery_format = " [{battery}%]",
        default_timeout = 20,
        mouse_callbacks = {
            "Button1": lazy.spawn(f"{qtile_home_path}/rofi/rofi-bluetooth-contained"),
        },
        padding = 10,
    ),
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    widget.Wlan(
        interface = qtilemachine.wireless_interface,
        format = "󰖩 {percent:2.0%}",
        disconnected_message = "󰖪 ",
        ethernet_message_format = "󰈀 ",
        use_ethernet = True,
        ethernet_interface = qtilemachine.wired_interface,
        mouse_callbacks={
            "Button1": lambda: qtile.spawn("networkmanager_dmenu"),
        },
        padding = 10,
    ),
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    widget.PulseVolume(
        mute_format = "   ",
        unmute_format = " {volume}%",
        mute_foreground = qtilecolor.foreground_error,
        foreground = qtilecolor.foreground_main,
        padding = 10,
    ),
] + ([
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    widget.Backlight(
        mouse_callbacks={
            "Button1": lambda: qtile.spawn("sudo xbacklight -set 75"),
            "Button3": lambda: qtile.spawn("sudo xbacklight -set 25"),
            "Button4": lambda: qtile.spawn("sudo xbacklight -inc 3"),
            "Button5": lambda: qtile.spawn("sudo xbacklight -dec 3"),
        },
        fmt=" {}",
        backlight_name = qtilemachine.backlight_name,
        padding = 10,
    ),
] if qtilemachine.has_backlight else []) + [
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    widget.ThermalSensor(
        format = " {temp:.0f}{unit}",
        tag_sensor = qtilemachine.processor_temperature_name,
        mouse_callbacks={
            "Button1": lambda: qtile.spawn("alacritty -e btop"),
        },
        padding = 10,
    ),
] + ([
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    widget.Battery(
        format="{char} {percent:2.1%}  󱧦 {hour:02d}:{min:02d}",
        charge_char = "",
        discharge_char = "",
        full_char = "=",
        not_charging_char = "-",
        update_interval = 3,
        low_percentage = 0.2,
        low_foreground = qtilecolor.foreground_error,
        padding = 10
    ),
] if qtilemachine.has_battery else []) + [
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    widget.Clock(
        format="%Y-%m-%d %H:%M:%S",
        padding = 10,
    ),
]

# --- Screens ---

screens = [
    Screen(
        bottom=bar.Bar(
            widgets,
            24,
            background=qtilecolor.background_contrast,
            opacity=1.0,
        ),
    ),
]

# --- Other Settings ---

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = False
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "LG3D"
