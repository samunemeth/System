# --- Imports ---

import os
import subprocess

from libqtile import bar, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook
from libqtile.widget import base

import importlib.util
import sys
spec = importlib.util.spec_from_file_location("qtilemachine", os.path.expanduser("~/.config/qtilemachine.py"))
qtilemachine = importlib.util.module_from_spec(spec)
sys.modules["qtilemachine"] = qtilemachine
spec.loader.exec_module(qtilemachine)


# --- Colors ---

color_background_main = "#14161B"
color_background_contrast = "#0A0B0E"
color_foreground_main = "#F2F4F3"
color_foreground_soft = "#D0D6DD"
color_foreground_error = "#DC4332"


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
    subprocess.Popen([script, color_background_main, xc, yc])



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
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +5%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-")),

    Key([], "XF86AudioRaiseVolume", lazy.spawn("pulseaudio-ctl up")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pulseaudio-ctl down")),
    Key([], "XF86AudioMute", lazy.spawn("pulseaudio-ctl mute")),

    Key([], "XF86AudioMicMute", lazy.spawn("pulseaudio-ctl mute-input")),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),

    Key([], "XF86Calculator", lazy.spawn("rofi -show calc -modi calc")),

    # Keyboard layout switching.
    Key([mod], "a", lazy.widget["keyboardlayout"].next_keyboard()),

    # Screenshot.
    Key([mod, "shift"], "s", lazy.spawn("scrot ~/Downloads/%b%d::%H%M%S.png", shell=True)),
    Key([], "Print", lazy.spawn("scrot ~/Downloads/%b%d::%H%M%S.png", shell=True)),


]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
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
    Group("N"),
    Group("M"),
]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
        ]
    )

layouts = [
    layout.Columns(
        border_width=2,
        border_focus=color_foreground_soft,
        border_normal=color_background_contrast,
    ),
    layout.Max(),
]


# Set global widget settings.
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


# --- Bottom Status Bar ---

widgets = [
    widget.GroupBox(
        this_current_screen_border = color_foreground_main,
        this_screen_border = color_foreground_main,
        borderwidth = 2,
        disable_drag = True,
    ),
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70,
    ),
    # widget.Notify(
    #     background_low = color_background_contrast,
    #     foreground_low = color_foreground_main,
    #     background_urgent = color_background_contrast,
    #     foreground_urgent = color_foreground_error,
    #     width = 300,
    #     scroll = True,
    #     scroll_delay = 1,
    #     scroll_step = 5,
    #     padding = 10,
    # ),
    # widget.Sep(
    #     linewidth = 2,
    #     padding = 10,
    #     size_percent = 70,
    # ),
    widget.WindowName(
        parse_text = shorten_widow_title,
        padding = 10,
    ),

    # --------------------------

    # widget.OpenWeather(
    #     cityid = 3052009,
    # ),
    # widget.Sep(
    #     linewidth = 2,
    #     padding = 10,
    #     size_percent = 70
    # ),
    # widget.CPU(
    #     format = " {load_percent:3.0f}% ",
    # ),
    # widget.ThermalSensor(
    #     format = "{temp:.0f}{unit}",
    #     tag_sensor = "Package id 0",
    # ),
    # widget.Memory(
    #     format = "{MemUsed:.1f}{mm}",
    #     measure_mem = "G",
    #     measure_swap = "G",
    #     padding = 10,
    # ),

    # Seafile status widget.

    # This still requires some work, as Seafile is a bit quirky, and not
    # well documented. When updating, the library seems to completely disappear
    # from the list, instead of changing status. (No clue why...)
    # Detecting the disappearance could be a way to detect sync, but as this
    # is probably a bug, I would not want to rely on in not being fixed.
    # Other possible states (that I have not seen in the wild) are listed here:
    # https://help.seafile.com/syncing_client/linux-cli/#status
    # Another option on top of this (that I have actually seen) is:
    #   Waiting for sync
    # I saw this message instead of an error, (bruh) as the logs showed http
    # error codes, that were caused by a request body size limit on my nginx
    # proxy. This could of course be fixed.
    
    # widget.GenPollCommand(
    #     update_interval = 1,
    #     cmd = "seaf-cli status | rg '^Notes\s+(\w+)' -or '$1'",
    #     shell = True,
    #     padding = 10,
    # ),

    # SeafileStatus(
    #     update_interval=1,
    #     format="Seafile: {status}",
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
        default_text = "󰂯: {num_connected_devices}",
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
        format = "{essid} {percent:2.0%}",
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
    widget.KeyboardLayout(
        configured_keyboards = qtilemachine.available_layouts,
        display_map = {
            "hu": "HU",
            "us": "US",
            "us dvp": "DV",
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
        mute_foreground = color_foreground_error,
        foreground = color_foreground_main,
        padding = 10,
    ),
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    # TODO: Implement a better way to manage screen brightness.
    widget.GenPollText(
        update_interval=3,  # seconds
        func=lambda: subprocess.check_output(
            ["bash", "-c", "brightnessctl | grep -oP '\\(\\K[0-9]+'"], text=True
        ).strip() + "%",
        mouse_callbacks={
            "Button1": lambda: qtile.spawn("brightnessctl set +10%"),
            "Button3": lambda: qtile.spawn("brightnessctl set 10%-"),
            "Button4": lambda: qtile.spawn("brightnessctl set 5%-"),
            "Button5": lambda: qtile.spawn("brightnessctl set +5%"),
        },
        fmt=" {}",
        padding = 10
    ),
    # widget.Backlight(
    #     backlight_name = "intel_backlight",
    #     padding = 10,
    # ),
    widget.Sep(
        linewidth = 2,
        padding = 10,
        size_percent = 70
    ),
    widget.Battery(
        format="{char} {percent:2.1%} {watt:.0f}W",
        charge_char = "",
        discharge_char = "",
        full_char = "=",
        not_charging_char = "-",
        update_interval = 3,
        low_percentage = 0.2,
        low_foreground = color_foreground_error,
        padding = 10
    ),
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
screens = [
    Screen(
        bottom=bar.Bar(
            widgets,
            24,
            background=color_background_contrast,
            opacity=1.0,
        ),
    ),
]

# Drag floating layouts.
# mouse = [
#     Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
#     Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
#     Click([mod], "Button2", lazy.window.bring_to_front()),
# ]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
# floats_kept_above = True
cursor_warp = False
# floating_layout = layout.Floating(
#     float_rules=[
#         # Run the utility of `xprop` to see the wm class and name of an X client.
#         *layout.Floating.default_float_rules,
#         Match(wm_class="confirmreset"),  # gitk
#         Match(wm_class="makebranch"),  # gitk
#         Match(wm_class="maketag"),  # gitk
#         Match(wm_class="ssh-askpass"),  # ssh-askpass
#         Match(title="branchdialog"),  # gitk
#         Match(title="pinentry"),  # GPG key password entry
#     ]
# )
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = None
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
