# Copyright (c) 2010 Aldo Coresi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess

import libqtile.resources
from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from qtile_extras import widget
from qtile_extras.popup.templates.mpris2 import COMPACT_LAYOUT, DEFAULT_LAYOUT
from qtile_extras.widget.decorations import PowerLineDecoration
from qtile_extras.popup import (
    PopupRelativeLayout,
    PopupImage,
    PopupText
)



mod = "mod4"
my_term = "kitty"
term_exec = "kitty -e"
my_web = "firefox"
my_music = "rmpc"
my_music_stream = "spotify-launcher"

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call(home)

# Cleans up long .widget.WindowName
def clean_titles(text):
    if "Spotify Premium" in text:
        return text.replace("Spotify Premium", "Spotify")
    elif "yt-dlp" in text:
        return "yt-dlp download"
    for string in ["Firefox"]:
        if string in text:
            text = string
        else:
            text = text
    return text

# Inport pywal colorscheme
colors = []
cache='/home/Thirdscreen/.cache/wal/colors'
def load_colors(cache):
    with open(cache, 'r') as file:
        for i in range(16):
            colors.append(file.readline().strip())
    colors.append('#ffffff')
    lazy.reload()
load_colors(cache)

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"],"Return",lazy.layout.toggle_split(),desc="Toggle between split and unsplit sides of stack",),
    # Launch binds
    Key([mod], "Return", lazy.spawn(my_term),desc="Launch terminal"),
    Key([mod], "s", lazy.spawn({my_music_stream}),desc="Launch music streaming platform"),
    Key([mod], "m", lazy.spawn(f"{term_exec} {my_music}"),desc="Launch music player"),
    Key([mod], "w", lazy.spawn(my_web),desc="Launch browser"),
    Key([mod, "shift"], "n", lazy.spawn(f"{term_exec} nmtui"),desc="Launch Network Manager"),
    Key([mod, "shift"], "b", lazy.spawn(f"{term_exec} bluetui"),desc="Launch bluetooth manager"),
    Key([mod], "f", lazy.spawn(f"{term_exec} yazi"),desc="Launch file-manager"),
    Key([mod], "r", lazy.spawn("rofi -show drun"),desc="Launch rofi in drun mode"),
    Key([mod], "d", lazy.spawn("discord"),desc="Launch discord"),
    Key([mod, "shift"], "s", lazy.spawn("setwal"),desc="Open wallpaper menu"),
    Key([mod, "control"], "s", lazy.spawn("flameshot gui -p /home/Thirdscreen/pics/Screenshots/"),desc="Select area for screenshot"),
    # Media controls
    Key([mod], "space", lazy.spawn("playerctl play-pause"), desc="Play/Pause player"),
    Key([mod], "Right", lazy.spawn("playerctl next"), desc="Skip to next"),
    Key([mod], "Left", lazy.spawn("playerctl previous"), desc="Hop back to previous"),
    Key([mod], "Up", lazy.spawn("playerctl volume 0.05+"), desc="Increase volume by 5%"),
    Key([mod], "Down", lazy.spawn("playerctl volume 0.05-"), desc="Decrease volume by 5%"),
    Key([mod, "shift"], "space", lazy.spawn("mpc toggle"), desc="Play/Pause player"),
    Key([mod, "shift"], "Right", lazy.spawn("mpc next"), desc="Skip to next"),
    Key([mod, "shift"], "Left", lazy.spawn("mpc prev"), desc="Hop back to previous"),
    Key([mod, "shift"], "Up", lazy.spawn("mpc volume +5"), desc="Increase volume by 5%"),
    Key([mod, "shift"], "Down", lazy.spawn("mpc volume -5"), desc="Decrease volume by 5%"),
    Key([mod], "F3", lazy.spawn("brightnessctl set 10%+"), desc="Increase screen brightness by 10%"),
    Key([mod], "F4", lazy.spawn("brightnessctl set 10%-"), desc="Decrease screen brightness by 10%"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window",),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod, "control"], "l", lazy.spawn("xlock"), desc="Lock Screen"),
    Key([mod, "shift"], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(["control", "mod1"],f"f{vt}",lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key([mod],i.name,lazy.group[i.name].toscreen(),desc=f"Switch to group {i.name}",),
            # mod + shift + group number = switch to & move focused window to group
            Key([mod, "shift"],i.name,lazy.window.togroup(i.name, switch_group=True),desc=f"Switch to & move focused window to group {i.name}",),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )
# Append ScratchPad to groups list
groups.append(
    ScratchPad("scratchpad", [
        # define a drop down terminal
        DropDown("mixer", "pavucontrol", width=0.4, height=0.4, x=0.3, y=0.1),
        #DropDown("nnn", "alacritty nnn -d -C", width=0.4, x=0.3, y=0.2),
        #doesn't work
        ]),
    )
keys.extend(
    [
        Key(["control"], "F1", lazy.group["scratchpad"].dropdown_toggle("mixer")),
        #Key(["control"], "2", lazy.group["scratchpad"].dropdown_toggle("nnn")),
        #doesn't work
    ]
)
    
layout_theme = {
    "border_width": 0,
    "margin": 6,
    "border_focus": "#d75f5f",
    "border_normal": "#8f3d3d",
}

layouts = [
    layout.Columns(**layout_theme),
    layout.Max(margin = 0),
    # Try more layouts by unleashing below layouts.
    #layout.Stack(num_stacks=2),
    #layout.Bsp(),
    #layout.Matrix(),
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    #layout.RatioTile(),
    #layout.Tile(),
    #layout.TreeTab(),
    #layout.VerticalTile(),
    #layout.Zoomy(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
    foreground=colors[15],
)
extension_defaults = widget_defaults.copy()

powerline = {
    "decorations": [
        PowerLineDecoration(path='arrow_right')
    ]
}



logo = os.path.join(os.path.dirname(libqtile.resources.__file__), "logo.png")
screens = [
    Screen(
        bottom=bar.Bar(
            [
                widget.CurrentLayout(
                    use_mask=True, 
                    mode='icon', 
                    foreground=colors[10],
                ),
                widget.GroupBox(
                    disable_drag=True, 
                    active=colors[15],
                    inactive=colors[8],
                    this_current_screen_border=colors[3],
                ),
                widget.Prompt(),
                widget.WindowName(parse_text=clean_titles, **powerline),
                widget.Mpris2(
                    format='{xesam:artist} - {xesam:title}', 
                    **powerline
                ),
                widget.Memory(
                    format='RAM:{MemUsed: .2f}{mm}/{MemTotal: .0f}{mm}', 
                    measure_mem='G',
                    background=colors[2],
                ),
                widget.CPU(
                    format='CPU usage: {load_percent}%', 
                    background=colors[2], 
                    **powerline
                ),
                widget.ThermalZone(background=colors[10], **powerline),
                widget.Battery(
                    format='{char}{percent:2.0%}', 
                    background=colors[9], 
                    **powerline
                ),
                widget.Clock(format="%a %d-%m %H:%M", background=colors[1]),
            ],
            24,
            background=colors[0],
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            #border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ))]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
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
wmname = "GrandWizardWM"
