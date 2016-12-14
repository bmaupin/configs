#!/bin/bash

# Get the full path of the directory this script is in
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Parse command-line options
. $SCRIPTPATH/../ubuntu-common/getopts.sh "$@"


# Configure Xfce Terminal
wget https://raw.githubusercontent.com/bmaupin/solarized-dark-high-contrast/master/xfce4-terminal/terminalrc -O ~/.config/xfce4/terminal/terminalrc
echo "FontName=DejaVu Sans Mono 11
MiscMenubarDefault=FALSE" >> ~/.config/xfce4/terminal/terminalrc
grep -q ScrollingOnOutput ~/.config/xfce4/terminal/terminalrc || echo "ScrollingOnOutput=FALSE" >> ~/.config/xfce4/terminal/terminalrc && sed -i -E 's/^ScrollingOnOutput=.*/ScrollingOnOutput=FALSE/' ~/.config/xfce4/terminal/terminalrc

# Remove unnecessary applications
sudo apt-get -y remove abiword gmusicbrowser gnumeric mousepad orage xchat xfce4-notes

# Remove the duplicate login screen entry
sudo mv /usr/share/xsessions/xfce.desktop /usr/share/xsessions/xfce.desktop.bak &> /dev/null

# Disable workspace wrapping
xfconf-query -c xfwm4 -p /general/wrap_layout -t bool -s false

# Set up workspaces in a 2x2 grid
echo "
xprop -root -f _NET_DESKTOP_LAYOUT 32cccc -set _NET_DESKTOP_LAYOUT 0,2,2,0
" >> ~/.profile
xprop -root -f _NET_DESKTOP_LAYOUT 32cccc -set _NET_DESKTOP_LAYOUT 0,2,2,0

# Configure keyboard shortcuts for moving windows to different workspaces
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Down" -t string -s "move_window_down_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Left" -t string -s "move_window_left_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Right" -t string -s "move_window_right_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Up" -t string -s "move_window_up_workspace_key"

# Configure compose key as right alt (for typing accented characters)
sudo sed -i.bak 's/^XKBOPTIONS=""/XKBOPTIONS="compose:ralt"/' /etc/default/keyboard
setxkbmap -option compose:ralt

# Enable tiling snap for windows by disabling the ability to drag windows between workspaces
xfconf-query -c xfwm4 -p /general/wrap_windows -s false

# Fix missing scrollbar arrow buttons with greybird theme
# https://bugs.launchpad.net/ubuntu/+source/shimmer-themes/+bug/881472
sudo sed -i.bak -E 's/(GtkScrollbar.+has.+stepper)/#&/' /usr/share/themes/Greybird/gtk-2.0/gtkrc

# Configurations for specific releases
if lsb_release -r | grep -q 16.04; then
    # Work around bug with /etc/default/keyboard
    # https://bugs.launchpad.net/ubuntu/+source/console-setup/+bug/1612951
    grep -q setxkbmap ~/.xprofile || echo "setxkbmap -option compose:ralt" >> ~/.xprofile
fi
