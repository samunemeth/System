# --- Imports ---

import os
import sys
import re

import subprocess
import importlib.util
from libqtile.log_utils import logger

from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.widget import base


# --- Parametric Settings ---

spec = importlib.util.spec_from_file_location("qtileparametric", os.path.expanduser("~/.config/qtileparametric.py"))
parametric = importlib.util.module_from_spec(spec)
sys.modules["parametric"] = parametric
spec.loader.exec_module(parametric)


# --- Guess Network Adapter Names ---

try:
    network_interfaces = subprocess.check_output(["ls", "/sys/class/net/"]).decode("utf-8").split("\n")
except:
    network_interfaces = []

try:
    wired_interface = next(filter(lambda e: e.startswith("e"), network_interfaces))
except:
    wired_interface = "eth0"

try:
    wireless_interface = next(filter(lambda e: e.startswith("w"), network_interfaces))
except:
    wireless_interface = "wlo1"


# --- Guess Backlight Name ---

try:
    backlight_name = subprocess.check_output(["ls", "/sys/class/backlight/"]).decode("utf-8").split("\n")[0]
except:
    backlight_name = ""


# --- Check Battery ---

try:
    power_supplies = subprocess.check_output(["ls", "/sys/class/power_supply/"]).decode("utf-8").split("\n")
    next(filter(lambda e: e.startswith("BAT"), power_supplies))
    has_battery = True
except:
    has_battery = False


# --- Guess Processor Temperature Sensor ---

try:
    temperature_sensors = subprocess.check_output(["sensors"]).decode("utf-8").split("\n")
    has_packageid = len(list(filter(lambda e: "Package id 0" in e, temperature_sensors)))
    has_tctl = len(list(filter(lambda e: "Tctl" in e, temperature_sensors)))
    if has_packageid:
        processor_temperature_name = "Package id 0"
    elif has_tctl:
        processor_temperature_name = "Tctl"
    else:
        processor_temperature_name = ""
except:
    processor_temperature_name = ""


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
    subprocess.Popen([script, parametric.background_main, xc, yc])


# --- Keyboard Shortcuts ---

def power_action(cmd):

    action = ""
    if cmd.startswith(("su", "sl")):
        action = "suspend"
    elif cmd.startswith("hi"):
        action = "hibernate"
    elif cmd.startswith("re"):
        action = "reboot"
    elif cmd.startswith(("po", "sh")):
        action = "poweroff"

    if action:
        subprocess.Popen(["systemctl", action])

@lazy.function
def power_prompt(qtile):
    qtile.widgets_map["response"].update("")
    qtile.widgets_map["prompt"].start_input("[power]:", power_action)

keys = [

    # Switching and moving windows.
    Key([mod], "h", lazy.layout.left(), desc="Focus Left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus Right"),
    Key([mod], "j", lazy.layout.down(), desc="Focus Down"),
    Key([mod], "k", lazy.layout.up(), desc="Focus Up"),

    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move Left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Moveto Right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move Down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move Up"),

    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow Left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow Right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow Down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow Up"),

    # Layout management.
    Key([mod], "e", lazy.layout.next(), desc="Move Focus"),
    Key([mod], "q", lazy.next_layout(), desc="Toggle Layouts"),
    Key([mod], "r", lazy.window.toggle_fullscreen(), desc="Fullscreen"),
    Key([mod], "v", lazy.window.kill(), desc="Kill Window"),
    Key([mod], "t", lazy.hide_show_bar(), desc="Hide/Show Bar"),

    # Toggle scratchpads.
    Key([mod], "f", lazy.group["scratchpad"].dropdown_toggle("lf")),
    Key([mod], "d", lazy.group["scratchpad"].dropdown_toggle("term")),
    Key([mod], "c", lazy.group["scratchpad"].dropdown_toggle("calc")),

    # Application quick launch
    Key([mod], "semicolon", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "w", lazy.spawn("firefox"), desc="Firefox"),

    # Move to next screen. Both on y and z to avoid confusion on qwertz keyboards.
    Key([mod], "y", lazy.next_screen(), desc="Next screen"),
    Key([mod], "z", lazy.next_screen(), desc="Next screen"),

    # Rofi menu options
    Key([mod], "g", lazy.spawncmd(prompt="$")),
    Key([mod], "s", power_prompt),
    Key([mod], "n", lazy.spawn("networkmanager_dmenu")),
    Key([mod], "b", lazy.spawn(f"{qtile_home_path}/rofi/rofi-bluetooth-contained")),
    Key([mod], "x", lazy.spawn(f"rofi -show rofi-sound -modi \"rofi-sound:{qtile_home_path}/rofi/rofi-sound-plugin\"")),
    Key([mod, "shift"], "w", lazy.spawn(f"rofi -show rofi-oath -modi \"rofi-oath:{qtile_home_path}/rofi/rofi-oath-plugin\"")),

    # Keyboard layout switching.
    Key([mod], "a", lazy.widget["keyboardlayout"].next_keyboard()),

    # Reload configuration.
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload Config"),

    # Screenshot.
    Key([mod, "shift"], "s", lazy.spawn("""
                                        mkdir -p ~/Screenshots
                                        scrot ~/Screenshots/screenshot-%Y-%m-%d-%H%M%S.png
                                        dunstify -u low "Screenshot saved."
                                        """, shell=True)),
    Key([], "Print", lazy.spawn("""
                                mkdir -p ~/Screenshots
                                scrot ~/Screenshots/screenshot-%Y-%m-%d-%H%M%S.png
                                dunstify -u low "Screenshot saved."
                                """, shell=True)),

    # Color picker that copies to clipboard.
    Key([mod, "shift"], "c", lazy.spawn("""
                                        xcolor | xclip -selection clipboard
                                        dunstify -u low "Copied hex code to clipboard."
                                        """, shell=True)),

    # Hardware key maps to commands.
    Key([], "XF86MonBrightnessUp", lazy.spawn("sudo xbacklight -inc 5")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("sudo xbacklight -dec 5")),

    Key([], "XF86AudioRaiseVolume", lazy.spawn("pulseaudio-ctl up")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pulseaudio-ctl down")),
    Key([], "XF86AudioMute", lazy.spawn("pulseaudio-ctl mute")),

    Key([], "XF86AudioMicMute", lazy.spawn("pulseaudio-ctl mute-input")),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),

    Key([], "XF86Calculator", lazy.group["scratchpad"].dropdown_toggle("calc")),

]


# --- Group Settings ---

groups = [

    Group("U", spawn=terminal),
    Group("I"),
    Group("O"),
    Group("P", spawn="firefox"),
    Group("M"),
    Group(","),
    Group("."),
    Group("/"),

    ScratchPad("scratchpad", [
        DropDown(
            "term",
            terminal,
            width = 0.8,
            height = 0.601,
            x = 0.1,
            y = 0.15,
            opacity = 1,
        ),
        DropDown(
            "lf",
            f"{terminal} -e lf",
            width = 0.8,
            height = 0.601,
            x = 0.1,
            y = 0.15,
            opacity = 1,
        ),
        DropDown(
            "calc",
            f"{terminal} -e calc",
            width = 0.8,
            height = 0.601,
            x = 0.1,
            y = 0.15,
            opacity = 1,
        ),
    ]),

]

group_key_lookup = {

    "U": "U",
    "I": "I",
    "O": "O",
    "P": "P",
    "M": "M",
    ",": "comma",
    ".": "period",
    "/": "slash",

}

for i in groups:
    if i.name == "scratchpad":
        continue
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


# --- Layout Settings ---


# Return number of connected outputs reported by xrandr.
def get_connected_monitors() -> int:
    try:
        out = subprocess.check_output(["xrandr", "--query"], stderr=subprocess.DEVNULL)
        out = out.decode("utf-8", errors="ignore")
    except Exception:
        return 1
    lines = [L for L in out.splitlines() if " connected" in L]
    return max(1, len(lines))

layouts = [
    layout.Columns(
        border_width = 2,
        border_focus = parametric.foreground_soft,
        border_normal = parametric.background_contrast,
        border_on_single = get_connected_monitors() > 1,
        single_border_width = 2,
    ),
]

floating_layout = layout.Floating(
    border_width = 2,
    border_focus = parametric.foreground_soft,
    border_normal = parametric.background_contrast,
    float_rules = [
        Match(wm_type="utility"),
        Match(wm_type="notification"),
        Match(wm_type="toolbar"),
        Match(wm_type="splash"),
        Match(wm_type="dialog"),
        Match(wm_class="file_progress"),
        Match(wm_class="confirm"),
        Match(wm_class="dialog"),
        Match(wm_class="download"),
        Match(wm_class="error"),
        Match(wm_class="notification"),
        Match(wm_class="splash"),
        Match(wm_class="toolbar"),
        Match(func=lambda c: c.has_fixed_size()),
        # Match(func=lambda c: c.has_fixed_ratio()), # Disabled for MPV.
    ]
)

# --- Widgets ---

def get_nvidia_status_icon():
    current_status = subprocess.check_output(["cat", f"{parametric.dgpu_path}/power/runtime_status"]).decode("utf-8").strip()
    if current_status == "active":
        return "󰨇"
    elif current_status == "suspended":
        return "󰍹"
    else:
        return "󰷜"

# TODO: Refactor this to be clearer.
def get_seafile_status():
    try: 
        seaf_status = subprocess.check_output(["seaf-cli", "status"]).decode("utf-8").strip()
        content_raw = [re.sub("\s+", " ", x.strip()).split(" ") for x in seaf_status.split("\n")[1:]]
        def get_status_icon(status_text):
            if status_text == "synchronized":
                return " "
            if status_text == "uploading":
                return " "
            if status_text == "downloading":
                return " "
            if status_text == "initializing":
                return "󰜝 "
            if status_text == "committing":
                return "󰜘 "
            if status_text == "waiting":
                return "󰔚 "
            if status_text == "error":
                return " "
            logger.warning(f"Unrecognised Seafile status: '{status_text}'. Raw content: '{content_raw}'")
            return status_text[0]
        content = [
            f"{
                lib[0]
            }: {
                get_status_icon(lib[1])
            }{
                '' if len(lib) < 3 else f' {lib[3 if lib[2] == "files" else 2]}' if lib[1] not in ['waiting', 'error'] else ''
            }"
            for lib in content_raw if lib[1] != "synchronized"]
        return " ".join(content)[:-1]
    except:
        return ""

# The default widget settings.
widget_defaults = dict(
    font = "Hack Nerd Font",
    foreground = parametric.foreground_main,
    fontsize = 14,
    padding = 10,
)
extension_defaults = widget_defaults.copy()

# The default separator.
def add_sep():
    return widget.Sep(
        linewidth = 2,
        size_percent = 70,
        foreground = "#888888",
        padding = 10,
    )

widgets = [

    widget.GroupBox(
        this_current_screen_border = parametric.foreground_main,
        this_screen_border = parametric.foreground_main,
        borderwidth = 2,
        disable_drag = True,
        urgent_alert_method = "text",
        urgent_text = parametric.foreground_main,
        padding = 3,
    ),
    add_sep(),

    widget.KeyboardLayout(
        configured_keyboards = parametric.available_layouts,
        display_map = {
            "hu": "HU",
            "us": "US",
            "us dvp": "DV",
            "us intl": "IN",
        },
    ),
    add_sep(),

    widget.GenPollText(
        func = get_seafile_status,
        fmt = "{}",
        shell = True,
        update_interval = 3, # NOTE: I'm not sure how much resources this uses.
    ),
    widget.Prompt(
        prompt = "{prompt} ",
        record_history = False,
        bell_style = None,
        cursor_color = parametric.foreground_main,
        cursor_type = "bar",
        cursorblink = .5,
        padding = 7,
    ),
    widget.TextBox(
        name = "response",
        padding = 7,
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
    #    # ),

    # --------------------------

    widget.Spacer(),

] + ([

    add_sep(),
    widget.GenPollText(
        func = get_nvidia_status_icon,
        fmt = "{}",
        shell = True,
        update_interval = 1,
    ),
    widget.Spacer(length=4),

] if not parametric.dgpu_path == "" else []) + [

    add_sep(),
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
    ),

    add_sep(),
    widget.Wlan(
        interface = wireless_interface,
        format = "󰖩 {percent:2.0%}",
        disconnected_message = "󰖪 ",
        ethernet_message_format = "󰈀 ",
        use_ethernet = True,
        ethernet_interface = wired_interface,
        mouse_callbacks = {
            "Button1": lazy.spawn("networkmanager_dmenu"),
        },
    ),

    add_sep(),
    widget.PulseVolume(
        mute_format = "   ",
        unmute_format = " {volume}%",
        mute_foreground = parametric.foreground_error,
    ),

] + ([

    add_sep(),
    widget.Backlight(
        mouse_callbacks = {
            "Button1": lazy.spawn("sudo xbacklight -set 75"),
            "Button3": lazy.spawn("sudo xbacklight -set 25"),
            "Button4": lazy.spawn("sudo xbacklight -inc 3"),
            "Button5": lazy.spawn("sudo xbacklight -dec 3"),
        },
        fmt=" {}",
        backlight_name = backlight_name,
    ),

] if backlight_name else []) + [

    add_sep(),
    widget.ThermalSensor(
        format = " {temp:.0f}{unit}",
        tag_sensor = processor_temperature_name,
        mouse_callbacks = {
            "Button1": lazy.spawn(f"{terminal} -e btop"),
        },
    ),

] + ([

    add_sep(),
    widget.Battery(
        format="{char} {watt:.0f}W  󰂎 {percent:2.1%}  󱧦 {hour:02d}:{min:02d}",
        charge_char = "",
        discharge_char = "",
        full_char = "=",
        not_charging_char = "-",
        update_interval = 3,
        low_percentage = 0.2,
        low_foreground = parametric.foreground_error,
    ),

] if has_battery else []) + [

    add_sep(),
    widget.Clock(
        format = "%Y-%m-%d %H:%M:%S",
    ),

]

# --- Screen Settings ---

screens = [
    Screen(
        bottom=bar.Bar(
            widgets,
            26,
            background = parametric.background_contrast,
            opacity = 1.0,
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
