#!/bin/sh

GNOME_VERSION=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)

cd /tmp
git clone https://github.com/mgalgs/gnome-shell-system-monitor-applet.git
cd gnome-shell-system-monitor-applet
# The packaged extension always has a version; set one manually
sed -i 's/"version": -1/"version": 75/' system-monitor-next@paradoxxx.zero.gmail.com/metadata.json
# Set shell-version to current GNOME version
# sed -i "s/\"shell-version\": \[.*\]/\"shell-version\": [\"$GNOME_VERSION\"]/" system-monitor@paradoxxx.zero.gmail.com/metadata.json
# BUILD_FOR_RPM=1 is a workaround for https://github.com/mgalgs/gnome-shell-system-monitor-applet/issues/102
BUILD_FOR_RPM=1 make install

# Cleanup
cd ..
rm -rf gnome-shell-system-monitor-applet
