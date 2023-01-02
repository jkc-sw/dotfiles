# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
# Copyright (c) 2021 Kuanju Chen
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

from typing import List  # noqa: F401
import os
from itertools import repeat
import subprocess
import glob

from libqtile import bar, layout, widget, hook
from libqtile.config import Drag, Group, Key, Match, Screen
from libqtile.core.manager import Qtile
from libqtile.lazy import lazy

mod = "mod1"
terminal = os.path.expanduser("~/repos/kitty/kitty.app/bin/kitty")


def add_key(modifiers: List[str], key: str, desc: str, *commands):
    return Key([e for e in modifiers if e], key, *commands, desc=desc)


def put_all_to_tile():
    """Send all the windows back to tile"""
    def cb(qtile: Qtile):
        g = qtile.current_group
        for w in g.windows:
            if w.floating:
                w.toggle_floating()

    return lazy.function(cb)


# Store the key map
# '<,'>Tab /,\zs/l0l1
keys = []
keys.extend([
    add_key([mod, "control", ""],        "h",      "Grow window to the left",            lazy.layout.grow_left()),
    add_key([mod, "control", ""],        "j",      "Grow window down",                   lazy.layout.grow_down()),
    add_key([mod, "control", ""],        "k",      "Grow window up",                     lazy.layout.grow_up()),
    add_key([mod, "control", ""],        "l",      "Grow window to the right",           lazy.layout.grow_right()),
    add_key([mod, "control", ""],        "Left",   "Grow window to the left",            lazy.layout.grow_left()),
    add_key([mod, "control", ""],        "Down",   "Grow window down",                   lazy.layout.grow_down()),
    add_key([mod, "control", ""],        "Up",     "Grow window up",                     lazy.layout.grow_up()),
    add_key([mod, "control", ""],        "Right",  "Grow window to the right",           lazy.layout.grow_right()),

    add_key([mod, "shift",   ""],        "h",      "Move window to the left",            lazy.layout.shuffle_left()),
    add_key([mod, "shift",   ""],        "j",      "Move window down",                   lazy.layout.shuffle_down()),
    add_key([mod, "shift",   ""],        "k",      "Move window up",                     lazy.layout.shuffle_up()),
    add_key([mod, "shift",   ""],        "l",      "Move window to the right",           lazy.layout.shuffle_right()),
    add_key([mod, "shift",   ""],        "Left",   "Move window to the left",            lazy.layout.shuffle_left()),
    add_key([mod, "shift",   ""],        "Down",   "Move window down",                   lazy.layout.shuffle_down()),
    add_key([mod, "shift",   ""],        "Up",     "Move window up",                     lazy.layout.shuffle_up()),
    add_key([mod, "shift",   ""],        "Right",  "Move window to the right",           lazy.layout.shuffle_right()),

    add_key([mod, "",        ""],        "h",      "Move focus to left",                 lazy.layout.left()),
    add_key([mod, "",        ""],        "j",      "Next windew",                        lazy.group.next_window()),
    add_key([mod, "",        ""],        "k",      "Previous windew",                    lazy.group.prev_window()),
    # add_key([mod, "",        ""],        "j",      "Move focus down",                    lazy.layout.down()),
    # add_key([mod, "",        ""],        "k",      "Move focus up",                      lazy.layout.up()),
    add_key([mod, "",        ""],        "l",      "Move focus to right",                lazy.layout.right()),
    add_key([mod, "",        ""],        "o",      "Move window focus to next window",   lazy.layout.next()),

    add_key([mod, "shift",   ""],        "n",      "Reset all window sizes",             lazy.layout.normalize()),
    add_key([mod, "",        ""],        "t",      "Toggle the window to floating",      lazy.window.toggle_floating()),
    add_key([mod, "shift",   ""],        "t",      "Put all windows back to tile",       put_all_to_tile()),
    add_key([mod, "",        ""],        "a",      "Go back to the last group",          lazy.screen.toggle_group()),
    add_key([mod, "",        ""],        "f",      "Toggle full screen",                 lazy.window.toggle_fullscreen()),
    add_key([mod, "",        ""],        "n",      "To the next group",                  lazy.screen.next_group()),
    add_key([mod, "",        ""],        "p",      "To the prev group",                  lazy.screen.prev_group()),
    add_key([mod, "",        ""],        "space",  "Toggle between layouts",             lazy.next_layout()),
    add_key([mod, "",        ""],        "q",      "Kill focused window",                lazy.window.kill()),

    add_key([mod, "shift",   "control"], "q",      "Shutdown Qtile",                     lazy.shutdown()),
    add_key([mod, "shift",   ""],        "y",      "Second level startup",               lazy.spawn(os.path.expanduser("~/.local/bin/wm_start_adv.sh"))),
    add_key([mod, "shift",   ""],        "q",      "Restart Qtile",                      lazy.restart()),
    add_key([mod, "shift",   ""],        "c",      "Lock the screen",                    lazy.spawn("xscreensaver-command -lock")),
    add_key([mod, "shift",   "control"], "c",      "Sleep the computer",                 lazy.spawn("bash -c \"xscreensaver-command -lock ; sleep 5 ; systemctl suspend\"")),

    add_key([mod, "shift",   ""],        "Return", "Launch terminal",                    lazy.spawn(terminal)),
    add_key([mod, "",        ""],        "x",      "Launch arandr",                      lazy.spawn("arandr")),
    add_key([mod, "shift",   ""],        "v",      "Launch volume control",              lazy.spawn("pavucontrol")),
    add_key([mod, "",        ""],        "v",      "Louder",                             lazy.spawn("amixer -D pulse -q set Master 5%+")),
    add_key([mod, "",        ""],        "z",      "Quieter",                            lazy.spawn("amixer -D pulse -q set Master 5%-")),
    add_key([mod, "shift",   ""],        "z",      "Mute",                               lazy.spawn("amixer -D pulse -q set Master toggle")),
    add_key([mod, "",        ""],        "b",      "Dimmer",                             lazy.spawn("xbacklight -dec 10")),
    add_key([mod, "shift",   ""],        "b",      "Brighter",                           lazy.spawn("xbacklight -inc 10")),
    add_key([mod, "shift",   ""],        "p",      "Open dmenu to start a program",      lazy.spawn("dmenu_run -p 'Run > '")),
    add_key([mod, "",        ""],        "g",      "From /tmp/c.txt to clipboard",       lazy.spawn(os.path.expanduser("~/.local/bin/pc"))),
    add_key([mod, "shift",   ""],        "s",      "Take a screenshot with select tool", lazy.spawn(os.path.expanduser("~/.local/bin/shot -s"))),
    add_key([mod, "",        ""],        "s",      "Take a full screenshot",             lazy.spawn(os.path.expanduser("~/.local/bin/shot"))),
])

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
]

groups = [Group(i) for i in "123456789"]

# Manual way to bind the key
keys.extend(
    add_key([mod, ''], i.name, "Switch to group {}".format(i.name), lazy.group[i.name].toscreen(toggle=False))
    for i in groups
)
keys.extend(
    add_key([mod, "shift"], i.name, "Switch to & move focused window to group {}".format(i.name), lazy.window.togroup(i.name, switch_group=False))
    for i in groups
)


def send_to_screen(n: int):
    """Send the current window to screen n

    Args:
        n (int): Screen index
    """
    def cb(qtile: Qtile):
        screens = qtile.screens

        if n < len(screens):
            # find what group it is on
            gp = screens[n].group.name

            if qtile.current_window:
                qtile.current_window.togroup(gp, switch_group=False)

    return lazy.function(cb)


keys.extend(
    add_key([mod, ""], k, "Go to screen {}".format(ii), lazy.to_screen(ii))
    for ii, k in enumerate(('w', 'e', 'r'))
)

keys.extend(
    add_key([mod, "shift"], k, "Go to screen {}".format(ii), send_to_screen(ii))
    for ii, k in enumerate(('w', 'e', 'r'))
)

# # Auto bind the key to switch to group
# from libqtile.dgroups import simple_key_binder
# dgroups_key_binder = simple_key_binder(mod)


# Default theme
myDefault_themes = dict(
    border_width=2,
    margin=6,
    fair=True,
    border_focus="#46d9ff",
    border_normal="#282c34",
    margin_on_single=6
)

# Run the utility of `xprop` to see the wm class and name of an X client.
floating_layout = layout.Floating(float_rules=[
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
], **myDefault_themes)

# Layout
layouts = [
    layout.Columns(**myDefault_themes),
    layout.Bsp(**myDefault_themes),
]

widget_defaults = dict(
    font='Noto Sans CJK TC',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


myGroupBoxProps = dict(
    disable_drag=True,
    borderwidth=2,
    this_current_screen_border='#31e710',
    this_screen_border='#bababa',
    other_screen_border='#bababa'
)

# Bar setup
myBarsPrimary = [
    widget.Volume(device='pulse'),
    widget.Sep(),
    widget.CurrentLayout(),
    widget.Sep(),
    widget.GroupBox(**myGroupBoxProps),
    widget.Sep(),
    widget.WindowCount(fmt='# {}'),
    widget.Sep(),
    widget.TaskList(title_width_method='uniform', padding=1),
    widget.Systray(),
    widget.StatusNotifier(),
    widget.Chord(
        chords_colors={
            'launch': ("#ff0000", "#ffffff"),
        },
        name_transform=lambda name: name.upper(),
    ),
    widget.Sep(),
    widget.Clock(format='%Y-%m-%d %a %I:%M %p'),
    widget.Sep(),
    widget.QuickExit(),
]

myBarsSecondary = [
    widget.CurrentLayout(),
    widget.Sep(),
    widget.GroupBox(**myGroupBoxProps),
    widget.Sep(),
    widget.WindowCount(fmt='# {}'),
    widget.Sep(),
    widget.TaskList(title_width_method='uniform', padding=1),
]

# If the battery is there, use it
bats = glob.glob("/sys/class/power_supply/BAT*")
if len(bats) > 0:
    myBarsPrimary.insert(0, widget.BatteryIcon())
    myBarsPrimary.insert(0, widget.Battery())
    myBarsPrimary.insert(2, widget.Sep())

# Add primary screen
screens = [
    Screen(
        top=bar.Bar(
            myBarsPrimary,
            24,
        ),
    ),
]

# Add many secondary screens
screens.extend(repeat(Screen(
    top=bar.Bar(
        myBarsSecondary,
        24,
    ),
), 3))


@hook.subscribe.startup_complete
def start_once():
    subprocess.call(os.path.expanduser('~/.local/bin/wm_start.sh'))


dgroups_app_rules = []  # type: List
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = False
wmname = "LG3D"
