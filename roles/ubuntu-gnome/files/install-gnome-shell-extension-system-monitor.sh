#!/bin/sh

cd /tmp
git clone https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet.git
cd gnome-shell-system-monitor-applet
# The packaged extension always has a version; set one manually
sed -i 's/"version": -1/"version": 42/' system-monitor@paradoxxx.zero.gmail.com/metadata.json
make install

# Cleanup
cd ..
rm -rf gnome-shell-system-monitor-applet
