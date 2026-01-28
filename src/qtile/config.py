# --- Imports ---

import os
import re

import subprocess
from libqtile.log_utils import logger
from dataclasses import dataclass
import urllib.request, urllib.parse
import json
import datetime

from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal


# --- Logging ---

logger.info("--- STARTING ---")


# --- Parametric Settings ---

def get_parametric():
    with open("/etc/system-options/globals.json", "r", encoding="utf-8") as f:
        globals_ = json.load(f)
    with open("/etc/system-options/modules.json", "r", encoding="utf-8") as f:
        modules_ = json.load(f)
    is_vm_ = bool(os.getenv("IS_VM"))
    
    @dataclass
    class parametric_:
        background_main = globals_["colors"]["background"]["main"]
        background_contrast = globals_["colors"]["background"]["contrast"]
        foreground_main = globals_["colors"]["foreground"]["main"]
        foreground_soft = globals_["colors"]["foreground"]["soft"]
        foreground_error = globals_["colors"]["foreground"]["error"]
        available_layouts = modules_["locale"]["keyboardLayouts"]
        has_hibernation = modules_["system"]["hibernation"]
        has_auto_login = modules_["boot"]["autoLogin"]
        dgpu_path = "" # Placeholder for now.
        is_vm = is_vm_
    return parametric_

def get_dummy_parametric():
    @dataclass
    class parametric_:
        background_main = "#222222"
        background_contrast = "#000000"
        foreground_main = "#FFFFFF"
        foreground_soft = "#DDDDDD"
        foreground_error = "#FF0000"
        available_layouts = "us"
        has_hibernation = True
        has_auto_login = False
        dgpu_path = ""
        is_vm = True # Assume that we are in a VM of sorts.
    return parametric_

try:
    parametric = get_parametric()
except:
    parametric = get_dummy_parametric()

if parametric.is_vm:
    logger.warning("Running inside virtual machine! Some widgets disabled.")


# --- Secrets ---

# Load in secrets from sops. The paths are constant here, assuming that the
# secrets name is not changed in sops this should be fine.

try:
    with open("/run/secrets/google-cal-id", "r", encoding="utf-8") as f:
        GOOGLE_CAL_ID = f.read().strip()
    with open("/run/secrets/google-api-key", "r", encoding="utf-8") as f:
        GOOGLE_API_KEY = f.read().strip()
except FileNotFoundError:
    GOOGLE_API_KEY = ""
    GOOGLE_CAL_ID = ""


# --- Configuration Location ---

try:
    qtile_home_path = os.path.realpath(os.path.dirname(qtile.config.file_path))
except AttributeError:
    qtile_home_path = os.path.expanduser("~/.config/qtile")
rofi_path = qtile_home_path + "/rofi"
logger.info(f"Running with config path: {qtile_home_path}")

# --- Guess Network Adapter Names ---

try:
    network_interfaces = subprocess.check_output(["ls", "/sys/class/net/"]).decode("utf-8").split("\n")
except:
    network_interfaces = []

wired_interface = next(filter(lambda e: e.startswith("e"), network_interfaces), "")
wireless_interface = next(filter(lambda e: e.startswith("w"), network_interfaces), "")


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


# --- Hooks ---

# Run a startup script.
@hook.subscribe.startup
def autostart():

    # Get the absolute path of the startup script.
    script = os.path.expanduser(f"{qtile_home_path}/autostart.sh")

    # Get the coordinates of the center of the main screen.
    xc = str(screens[0].x + screens[0].width // 2)
    yc = str(screens[0].y + screens[0].height // 2)

    # Run the startup script with the parameters.
    subprocess.Popen([script, parametric.background_main, xc, yc])

# Update some widgets on network connection.
@hook.subscribe.user("network_connected")
def hooked_function():

    # Update the calendar widget.
    qtile.widgets_map["calendar"].force_update()


# --- Keyboard Shortcuts ---

screenshot_script = """
mkdir -p ~/Screenshots
scrot ~/Screenshots/screenshot-%Y-%m-%d-%H%M%S.png
notify-send -u low "Screenshot saved."
"""

color_picker_script = """
xcolor | xclip -selection clipboard
notify-send -u low "Copied hex code to clipboard."
"""

def power_action(cmd):

    action = []
    if cmd.startswith(("su", "sl")):
        action = ["suspend"]
    elif cmd.startswith("hi"):
        action = ["hibernate"]
    elif cmd.startswith("re"):
        action = ["reboot"]
    elif cmd.startswith("wi"):
        action = ["reboot", "--boot-loader-entry=auto-windows", "--boot-loader-menu=1"]
    elif cmd.startswith(("po", "sh")):
        action = ["poweroff"]

    if action:
        subprocess.Popen(["systemctl", *action])

@lazy.function
def power_prompt(qtile):
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
    Key([mod], "t", lazy.hide_show_bar(), desc="Toggle Bar"),

    # Toggle scratchpads.
    Key([mod], "f", lazy.group["scratchpad"].dropdown_toggle("lf"), desc="Scratchpad Lf Files"),
    Key([mod], "d", lazy.group["scratchpad"].dropdown_toggle("term"), desc="Scratchpad Terminal"),
    Key([mod], "c", lazy.group["scratchpad"].dropdown_toggle("calc"), desc="Scratchpad Calculator"),

    # Application quick launch
    Key([mod], "semicolon", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "w", lazy.spawn("firefox"), desc="Firefox"),

    # Move to next screen. Both on y and z to avoid confusion on qwertz keyboards.
    Key([mod], "y", lazy.next_screen(), desc="Next Screen"),
    Key([mod], "z", lazy.next_screen(), desc="Next Screen"),

    # Rofi menu options
    Key([mod], "g", lazy.spawncmd(prompt="[app]:"), desc="Spawn Prompt"),
    Key([mod], "s", power_prompt, desc="Power Prompt"),
    Key([mod], "n", lazy.spawn("networkmanager_dmenu"), desc="Rofi Network"),
    Key(
        [mod],
        "b",
        lazy.spawn(f"{rofi_path}/rofi-bluetooth-contained"),
        desc="Rofi Bluetooth"
    ),
    Key(
        [mod],
        "x",
        lazy.spawn(f'rofi -show sound -modi "sound:{rofi_path}/rofi-sound-plugin"'),
        desc="Rofi Sound"
    ),
    Key(
        [mod, "shift"],
        "w",
        lazy.spawn(f"rofi -show oath -modi \"oath:{rofi_path}/rofi-oath-plugin\""),
        desc="Rofi Yubikey Auth"
    ),

    # Keyboard layout switching.
    Key([mod], "a", lazy.widget["keyboardlayout"].next_keyboard(), desc="Keyboard Layout"),

    # Screenshot.
    Key([mod, "shift"], "s", lazy.spawn(screenshot_script, shell=True), desc="Screenshot"),
    Key([], "Print", lazy.spawn(screenshot_script, shell=True), desc="Screenshot"),

    # Color picker that copies to clipboard.
    Key([mod, "shift"], "c", lazy.spawn(color_picker_script, shell=True), desc="Color Picker"),

    # Hardware key maps to commands.
    Key([], "XF86MonBrightnessUp", lazy.spawn("sudo xbacklight -inc 5"), desc="Brightness Up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("sudo xbacklight -dec 5"), desc="Brightness Down"),

    Key([], "XF86AudioRaiseVolume", lazy.spawn("pulseaudio-ctl up"), desc="Volume Up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pulseaudio-ctl down"), desc="Volume Down"),
    Key([], "XF86AudioMute", lazy.spawn("pulseaudio-ctl mute"), desc="Volume Mute"),

    Key([], "XF86AudioMicMute", lazy.spawn("pulseaudio-ctl mute-input"), desc="Microphone Mute"),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play Pause"),

    Key([], "XF86Calculator", lazy.group["scratchpad"].dropdown_toggle("calc"), desc="Scratchpad Calculator"),

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
    "U": "u",
    "I": "i",
    "O": "o",
    "P": "p",
    "M": "m",
    ",": "comma",
    ".": "period",
    "/": "slash",
}

for name, key in group_key_lookup.items():
    keys.append(
       Key(
           [mod],
           key,
           lazy.group[name].toscreen(),
           desc=f"Group {name}",
       )
    )
    keys.append(
       Key(
           [mod, "shift"],
           key,
           lazy.window.togroup(name, switch_group=True),
           desc=f"Move to {name}",
       )
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

def get_seafile_status():
    try: 
        seaf_status = subprocess.check_output(["seaf-cli", "status"]).decode("utf-8").strip()
        content_raw = [re.sub(r"\s+", " ", x.strip()).split(" ") for x in seaf_status.split("\n")[1:]]
        def get_status_icon(status_text):
            icons = {
                "synchronized": " ",
                "uploading": " ",
                "downloading": " ",
                "initializing": "󰜝 ",
                "committing": "󰜘 ",
                "waiting": "󰔚 ",
                "error": " ",
            }
            if status_text in icons:
                return icons[status_text]
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


def get_next_calendar_event(link_only=False):

    # Return some defaults if there is no API key.
    if not GOOGLE_API_KEY or not GOOGLE_CAL_ID:
        if link_only:
            return "about:blank"
        return "<i>(No API Key)</i>"

    cal_id_enc = urllib.parse.quote(GOOGLE_CAL_ID)
    time_now = datetime.datetime.now(datetime.UTC)

    # TODO: Only allow events from the current day / from the next 24h
    params = {
        "key": GOOGLE_API_KEY,
        "singleEvents": "true",
        "orderBy": "startTime",
        "timeMin": time_now.isoformat(),
        "maxResults": "5",
        "showDeleted": "false",
    }
    params_enc = urllib.parse.urlencode(params)
    url = f"https://www.googleapis.com/calendar/v3/calendars/{cal_id_enc}/events?{params_enc}"

    try:
        with urllib.request.urlopen(url) as resp:
            data = json.load(resp)
    except:
        
        # Return some defaults if there is no connection.
        if link_only:
            return "about:blank"
        return "<i>(No Connection)</i>"

    events = data.get("items", [])
    events = filter(lambda e: e["start"].get("date") is None, events)
    next_event = next(events, None)

    if link_only:
        return next_event["htmlLink"]

    time_format = "%H:%M"
    start_str = next_event["start"]["dateTime"]
    start_dt = datetime.datetime.fromisoformat(start_str).astimezone()
    start = start_dt.strftime(time_format)
    end_str = next_event["end"]["dateTime"]
    end_dt = datetime.datetime.fromisoformat(end_str).astimezone()
    end = end_dt.strftime(time_format)
    time = ("󰃭 " + start) if start_dt > time_now else ("󰃰 " + end)

    title = next_event.get("summary", "(No Title)")
    location = next_event.get("location", "")
    
    return f"{time} - <i>{title}</i>" + (f" - {location}" if location else "")

@lazy.function
def calendar_clicked(qtile):
    subprocess.Popen(["firefox", get_next_calendar_event(link_only=True)])

    firefox_window = next(filter(lambda e: "Firefox" in e["name"], qtile.windows()))
    firefox_group_name = firefox_window["group"]
    firefox_group_object = next(filter(lambda e: e.info()["name"] == firefox_group_name, qtile.groups))
    firefox_group_object.toscreen()

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

] + ([

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

] if not parametric.is_vm and len(parametric.available_layouts) > 1 else []) + ([

    widget.GenPollText(
        name = "calendar",
        func = get_next_calendar_event,
        fmt = "{}",
        update_interval = 60,
        mouse_callbacks = {
            "Button1": calendar_clicked,
        },
        
    ),
    add_sep(),

    widget.GenPollText(
        func = get_seafile_status,
        fmt = "{}",
        update_interval = 3, # NOTE: I'm not sure how much resources this uses.
    ),

] if not parametric.is_vm else []) + [

    widget.Prompt(
        prompt = "{prompt} ",
        record_history = False,
        bell_style = None,
        cursor_color = parametric.foreground_main,
        cursor_type = "bar",
        cursorblink = .5,
        padding = 7,
    ),

    # --------------------------

    # widget.TextBox(
    #     name = "response",
    #     padding = 7,
    # ),

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

] if not parametric.dgpu_path == "" else []) + ([

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
            "Button1": lazy.spawn(f"{rofi_path}/rofi-bluetooth-contained"),
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
        mouse_callbacks = {
            "Button1": lazy.widget["pulsevolume"].mute(),
            # NOTE: This is acting a bit oddly.
            "Button3": lazy.widget["pulsevolume"].decrease_vol(value=0.001),
            "Button4": lazy.widget["pulsevolume"].decrease_vol(),
            "Button5": lazy.widget["pulsevolume"].increase_vol(),
        },
    ),

] if not parametric.is_vm else []) + ([

    add_sep(),
    widget.Backlight(
        mouse_callbacks = {
            "Button1": lazy.spawn("sudo xbacklight -set 75"),
            "Button3": lazy.spawn("sudo xbacklight -set 25"),
            "Button4": lazy.spawn("sudo xbacklight -dec 3"),
            "Button5": lazy.spawn("sudo xbacklight -inc 3"),
        },
        fmt=" {}",
        backlight_name = backlight_name,
    ),

] if backlight_name else []) + ([

    add_sep(),
    widget.ThermalSensor(
        format = " {temp:.0f}{unit}",
        tag_sensor = processor_temperature_name,
        mouse_callbacks = {
            "Button1": lazy.spawn(f"{terminal} -e btop"),
        },
    ),

] if processor_temperature_name else []) + ([

    add_sep(),
    widget.Battery(
        format="{char} {watt:.0f}W  󰂎 {percent:2.1%}  󱧦 {hour:02d}:{min:02d}",
        charge_char = "",
        discharge_char = "",
        full_char = "=",
        empty_char = "x",
        not_charging_char = "-",
        update_interval = 3,
        low_percentage = 0.2,
        low_foreground = parametric.foreground_error,
        show_short_text = False,
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
focus_on_window_activation = "never"
reconfigure_screens = True
auto_minimize = False
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "LG3D"
