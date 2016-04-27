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

# Configure keyboard shortcuts for moving windows to different workspaces
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Control><Shift><Alt>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Control><Shift><Alt>Up']"

# Add minimize button back
gsettings set org.gnome.shell.overrides button-layout ':minimize,close'

# Don’t attach modal dialogs
# http://stackoverflow.com/a/20793282/399105
gsettings set org.gnome.shell.overrides attach-modal-dialogs false

# Enable delete in file manager
gsettings set org.gnome.nautilus.preferences enable-delete true

# Move tray icons to the top
mkdir -p ~/.local/share/gnome-shell/extensions
#mkdir -p ~/workspace/git/
#cd ~/workspace/git
#git clone http://94.247.144.115/~git/topicons.git
#cp -r topicons/ ~/.local/share/gnome-shell/extensions/topIcons@adel.gadllah@gmail.com
wget https://repo.dray.be/package-files/topicons-28.tar.gz
tar -xf topicons-28.tar.gz
mv -T topicons-28 ~/.local/share/gnome-shell/extensions/topIcons@adel.gadllah@gmail.com
rm -rf topicons-28*
gsettings set org.gnome.shell enabled-extensions "$(gsettings get org.gnome.shell enabled-extensions | sed -e "s/']/', ]/" | sed -e "s/]$/'topIcons@adel.gadllah@gmail.com']/")"

# Install system monitor
mkdir -p ~/.local/share/gnome-shell/extensions
mkdir -p ~/workspace/git/
cd ~/workspace/git/
git clone git://github.com/paradoxxxzero/gnome-shell-system-monitor-applet.git
cp -r gnome-shell-system-monitor-applet/system-monitor@paradoxxx.zero.gmail.com ~/.local/share/gnome-shell/extensions/
gsettings set org.gnome.shell enabled-extensions "$(gsettings get org.gnome.shell enabled-extensions | sed -e "s/']/', ]/" | sed -e "s/]$/'system-monitor@paradoxxx.zero.gmail.com']/")"
sudo cp ~/workspace/git/gnome-shell-system-monitor-applet/system-monitor@paradoxxx.zero.gmail.com/schemas/org.gnome.shell.extensions.system-monitor.gschema.xml /usr/share/glib-2.0/schemas/
cd /usr/share/glib-2.0/schemas
sudo glib-compile-schemas .
gsettings set org.gnome.shell.extensions.system-monitor cpu-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor cpu-show-text false
gsettings set org.gnome.shell.extensions.system-monitor disk-display true
gsettings set org.gnome.shell.extensions.system-monitor disk-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor disk-show-text false
gsettings set org.gnome.shell.extensions.system-monitor icon-display false
gsettings set org.gnome.shell.extensions.system-monitor memory-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor memory-show-text false
gsettings set org.gnome.shell.extensions.system-monitor net-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor net-show-text false
gsettings set org.gnome.shell.extensions.system-monitor swap-display true
gsettings set org.gnome.shell.extensions.system-monitor swap-graph-width 50
gsettings set org.gnome.shell.extensions.system-monitor swap-show-text false
