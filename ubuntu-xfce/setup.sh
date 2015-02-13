#!/bin/bash

# Get the full path of the directory this script is in
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Parse command-line options
. $SCRIPTPATH/../ubuntu-common/getopts.sh "$@"


# Create symlinks for config files
ln -s $SCRIPTPATH/.config/xfce4/terminal/terminalrc ~/.config/xfce4/terminal/terminalrc

# Disable workspace wrapping
xfconf-query -c xfwm4 -p /general/wrap_layout -t bool -s false

# Configure keyboard shortcuts for moving windows to different workspaces
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Down" -t string -s "move_window_down_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Left" -t string -s "move_window_left_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Right" -t string -s "move_window_right_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Up" -t string -s "move_window_up_workspace_key"

# Configure compose key as right alt (for typing accented characters)
sudo sed -i.bak 's/^XKBOPTIONS=""/XKBOPTIONS="compose:ralt"/' /etc/default/keyboard
setxkbmap -option compose:ralt
