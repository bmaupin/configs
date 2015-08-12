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

# Remove unnecessary packages
sudo apt-get -y autoremove empathy evolution

# Install packages
sudo apt-get -y install apt-file aptitude brasero deja-dup gedit gnote icedtea-7-plugin indicator-multiload libreoffice-calc libreoffice-impress libreoffice-writer nmap openjdk-7-jdk pidgin pidgin-sipe python3 remmina rhythmbox shotwell vim
# Install LibreOffice French support
sudo apt-get -y install hyphen-fr libreoffice-l10n-fr myspell-fr mythes-fr

# Install newer versions of buggy packages that come with 14.04
if lsb_release -r | grep -q 14.04; then
    wget https://launchpad.net/ubuntu/+archive/primary/+files/pidgin-sipe_1.18.2-1_amd64.deb
    sudo dpkg -i pidgin-sipe_1.18.2-1_amd64.deb
    rm pidgin-sipe_1.18.2-1_amd64.deb

    sudo apt-add-repository -y ppa:remmina-ppa-team/remmina-next
    sudo apt-get update
    sudo apt-get install -y libfreerdp-plugins-standard remmina
fi

# Update apt-file cache
sudo apt-file update

# Configure applications to run at start
mkdir -p ~/.config/autostart
ln -s /usr/share/applications/indicator-multiload.desktop ~/.config/autostart/indicator-multiload.desktop

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

# Configure Deja Dup (Backup) frequency of full backups
gsettings set org.gnome.DejaDup full-backup-period 180
# Configure length of time to keep backups for since there's currently no way to limit by size
# (https://bugs.launchpad.net/deja-dup/+bug/846852)
gsettings set org.gnome.DejaDup delete-after 730

# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Change Chrome language
cp /usr/share/applications/google-chrome.desktop ~/.local/share/applications/
sed -i 's/^Exec=\/usr\/bin\/google-chrome-stable/Exec=env LANGUAGE=fr \/usr\/bin\/google-chrome-stable/g' ~/.local/share/applications/google-chrome.desktop

# Default to Python 3 for future-proofing
echo "alias python=python3" >> ~/.bashrc

# Location-based configuration
if [ "$LOCATION" == "home" ]; then
    # Install packages
    sudo apt-get -y install gtk-redshift

    # Configure applications to run at start
    ln -s /usr/share/applications/redshift-gtk.desktop ~/.config/autostart/redshift-gtk.desktop

    # Disable daily mlocate update
    sudo chmod -x /etc/cron.daily/mlocate
elif [ "$LOCATION" == "work" ]; then
    # Install packages
    sudo apt-get -y install language-pack-fr myspell-fr thunderbird thunderbird-locale-fr

    # Install prerequisite packages for kernel modules for VirtualBox
    sudo apt-get -y install build-essential dkms linux-headers-generic

    # Change Thunderbird language
    cp /usr/share/applications/thunderbird.desktop ~/.local/share/applications/
    sed -i.bak 's/^Exec=thunderbird %u/Exec=env LC_ALL=fr_CA.utf8 thunderbird %u/' ~/.local/share/applications/thunderbird.desktop

    # Configure applications to run at start
    ln -s /usr/share/applications/gnote.desktop ~/.config/autostart/gnote.desktop
    ln -s /usr/share/applications/pidgin.desktop ~/.config/autostart/pidgin.desktop
    # Thunderbird needs a simpler entry for autostart or it won't work, in particular for Xfce
    printf "%s\n" \
        "[Desktop Entry]" \
        "Type=Application" \
        "Name=Thunderbird Mail" \
        "Icon=thunderbird" \
        "Exec=env LC_ALL=fr_CA.utf8 thunderbird" \
        "Terminal=false" > ~/.config/autostart/thunderbird.desktop

    # Fix headphone sound from rear jack on Dell Optiplex 9020
    sudo sh -c 'echo "set-sink-port 0 analog-output-headphones" >> /etc/pulse/default.pa'

    # Open firewall ports for pidgin-sipe outgoing file transfers
    # (http://repo.or.cz/w/siplcs.git/blob/HEAD:/src/core/sipe-ft.c)
    sudo ufw allow 6891:6901/tcp

    # Ignore certificate when using ldapsearch
    sudo cp -a /etc/ldap/ldap.conf /etc/ldap/ldap.conf.bak
    grep -q TLS_REQCERT /etc/ldap/ldap.conf || sudo sh -c 'echo TLS_REQCERT never >> /etc/ldap/ldap.conf'
fi
