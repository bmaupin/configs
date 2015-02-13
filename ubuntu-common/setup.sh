#!/bin/bash

# Get the full path of the directory this script is in
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Parse command-line options
. $SCRIPTPATH/getopts.sh "$@"


# Install packages
sudo apt-get install -y aptitude icedtea-7-plugin openjdk-7-jdk

# Create symlinks for config files
ln -s $SCRIPTPATH/.gitconfig ~/.gitconfig
ln -s $SCRIPTPATH/.vimrc ~/.vimrc

# Set up firewall
sudo ufw default deny  # (defaults to blocking all incoming connections)
sudo ufw enable  # (enables firewall)
sudo ufw status

# Disable update-apt-xapian-index
# (used for synaptic quick search function: http://reformedmusings.wordpress.com/2009/06/05/fixing-update-apt-xapian-in-ubuntu-9-04-jaunty/)
sudo chmod 644 /etc/cron.weekly/apt-xapian-index

# Configure grub
# Remove recovery menu entry
sudo sed -i.bak 's/^#GRUB_DISABLE_RECOVERY="true"$/GRUB_DISABLE_RECOVERY="true"/' /etc/default/grub
# Remove memory test menu entry
sudo chmod -x /etc/grub.d/20_memtest86+
sudo update-grub


# Location-based configuration
if [ "$LOCATION" = "home" ]
then
    # Install packages
    sudo apt-get -y install deja-dup

    # Disable daily mlocate update
    sudo chmod -x /etc/cron.daily/mlocate

    # Configure Deja Dup (Backup) full backup period
    gsettings set org.gnome.DejaDup full-backup-period 180
    gsettings get org.gnome.DejaDup full-backup-period
fi
