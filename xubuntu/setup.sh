#!/bin/bash

# Create symlinks for config files
ln -s ~/workspace/git/configs/xubuntu/.config/xfce4/terminal/terminalrc ~/.config/xfce4/terminal/terminalrc

# Disable workspace wrapping
xfconf-query -c xfwm4 -p /general/wrap_layout -t bool -s false

# Configure keyboard shortcuts for moving windows to different workspaces
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Down" -t string -s "move_window_down_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Left" -t string -s "move_window_left_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Right" -t string -s "move_window_right_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts --create -p "/xfwm4/custom/<Primary><Shift><Alt>Up" -t string -s "move_window_up_workspace_key"
