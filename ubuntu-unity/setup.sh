#!/bin/bash

# Configure compose key as right alt (for typing accented characters)
gsettings set org.gnome.desktop.input-sources xkb-options "['compose:ralt']"


# 14.04+
# Remove Amazon icon
sudo chmod 000 /usr/share/applications/ubuntu-amazon-default.desktop

# Disable online search results
gsettings set com.canonical.Unity.Lenses remote-content-search 'none'
