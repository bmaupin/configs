#!/bin/bash

# Get the full path of the directory this script is in
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Parse command-line options
. $SCRIPTPATH/getopts.sh "$@"


# Create symlinks for config files
ln -s $SCRIPTPATH/.gitconfig ~/.gitconfig
ln -s $SCRIPTPATH/.vimrc ~/.vimrc

# Install packages
sudo apt-get install -y aptitude brasero deja-dup gedit gnote icedtea-7-plugin indicator-multiload libreoffice nmap openjdk-7-jdk pidgin remmina rhythmbox shotwell

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

# Configure Deja Dup (Backup) full backup period
gsettings set org.gnome.DejaDup full-backup-period 180
gsettings get org.gnome.DejaDup full-backup-period


# Location-based configuration
if [ "$LOCATION" = "home" ]
then
    # Disable daily mlocate update
    sudo chmod -x /etc/cron.daily/mlocate
if [ "$LOCATION" = "work" ]
then
    # Install packages
    sudo apt-get -y install language-pack-fr myspell-fr thunderbird thunderbird-locale-fr

    # Change Thunderbird language
    cp /usr/share/applications/thunderbird.desktop ~/.local/share/applications/
    sed -i.bak 's/^Exec=thunderbird %u/Exec=env LC_ALL=fr_CA.utf8 thunderbird %u/' ~/.local/share/applications/thunderbird.desktop
fi
