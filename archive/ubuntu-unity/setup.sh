#!/bin/bash

# Get the full path of the directory this script is in
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Parse command-line options
. $SCRIPTPATH/../ubuntu-common/getopts.sh "$@"


# Configure compose key as right alt (for typing accented characters)
gsettings set org.gnome.desktop.input-sources xkb-options "['compose:ralt']"

# Solarize Gnome Terminal
bash <(curl -s https://raw.githubusercontent.com/bmaupin/solarized-dark-high-contrast/master/gnome-terminal/solarized-dark-high-contrast.sh)

# Hide Gnome Terminal menu bar
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/default_show_menubar" --type bool false

# Set up workspaces in a 2x2 grid
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 2
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 2

# Disable visual effects
gsettings set org.compiz.core:/org/compiz/profiles/Default/plugins/core/ active-plugins "`gsettings get org.compiz.core:/org/compiz/profiles/Default/plugins/core/ active-plugins | sed s/"'animation', "//`"
gsettings set org.compiz.core:/org/compiz/profiles/Default/plugins/core/ active-plugins "`gsettings get org.compiz.core:/org/compiz/profiles/Default/plugins/core/ active-plugins | sed s/"'fade', "//`"
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ active-plugins "`gsettings get org.compiz.core:/org/compiz/profiles/unity/plugins/core/ active-plugins | sed s/"'animation', "//`"


# 14.04+
# Remove Amazon icon
sudo chmod 000 /usr/share/applications/ubuntu-amazon-default.desktop

# Disable online search results
gsettings set com.canonical.Unity.Lenses remote-content-search 'none'


# 12.10+
# Disable keyboard shortcut overlay
dconf write /org/compiz/profiles/unity/plugins/unityshell/shortcut-overlay false

