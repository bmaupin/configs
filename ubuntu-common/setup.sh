#!/bin/bash

# Get the full path of the directory this script is in
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Parse command-line options
. $SCRIPTPATH/getopts.sh "$@"


# Set up firewall
sudo ufw default deny  # (defaults to blocking all incoming connections)
sudo ufw enable  # (enables firewall)
sudo ufw status

# Create symlinks for config files
ln -s $SCRIPTPATH/.gitconfig ~/.gitconfig
ln -s $SCRIPTPATH/.vimrc ~/.vimrc

# Remove undesired packages
sudo apt -y purge --auto-remove empathy evolution

# Install desired packages
sudo apt -y install apt-file bikeshed brasero deja-dup gedit indicator-multiload libreoffice-calc libreoffice-impress libreoffice-writer nmap pidgin pidgin-sipe python3 remmina rhythmbox shotwell vim

# Install LibreOffice French support
sudo apt -y install hyphen-fr libreoffice-l10n-fr myspell-fr mythes-fr

# Install release-specific packages
if [[ ! `lsb_release -r | awk '{print $2}'` < "16.04" ]]; then
    sudo apt -y install icedtea-8-plugin openjdk-8-jdk
else
    sudo apt -y install icedtea-7-plugin openjdk-7-jdk
fi

# Install newer versions of buggy packages that come with 14.04
if lsb_release -r | grep -q 14.04; then
    wget https://launchpad.net/ubuntu/+archive/primary/+files/pidgin-sipe_1.18.2-1_amd64.deb
    sudo dpkg -i pidgin-sipe_1.18.2-1_amd64.deb
    rm pidgin-sipe_1.18.2-1_amd64.deb

    sudo apt-add-repository -y ppa:remmina-ppa-team/remmina-next
    sudo apt update
    sudo apt install -y libfreerdp-plugins-standard remmina
fi

# Update apt-file cache
sudo apt-file update

# Reset indicator-multiload settings to default
# (http://askubuntu.com/a/858069/18665)
dconf reset -f "/de/mh21/indicator-multiload/"

# Configure indicator-multiload
gsettings set de.mh21.indicator-multiload.general autostart true
gsettings set de.mh21.indicator-multiload.graphs.load enabled true
gsettings set de.mh21.indicator-multiload.graphs.cpu enabled true
gsettings set de.mh21.indicator-multiload.graphs.disk enabled true
gsettings set de.mh21.indicator-multiload.graphs.net enabled true
gsettings set de.mh21.indicator-multiload.graphs.swap enabled true
gsettings set de.mh21.indicator-multiload.graphs.mem enabled true

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
sudo apt install -fy

# Change Chrome language
cp /usr/share/applications/google-chrome.desktop ~/.local/share/applications/
sed -i 's/^Exec=\/usr\/bin\/google-chrome-stable/Exec=env LANGUAGE=fr \/usr\/bin\/google-chrome-stable/g' ~/.local/share/applications/google-chrome.desktop

# Default to Python 3 for future-proofing
echo "alias python=python3" >> ~/.bashrc

# Set up permissions for debugging Google Android devices
sudo sh -c 'echo "\"SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", MODE=\"0666\", GROUP=\"plugdev\"" > /etc/udev/rules.d/51-android.rules'
# Set up permissions for debugging Motorola Android devices
sudo sh -c 'echo "\"SUBSYSTEM==\"usb\", ATTR{idVendor}==\"22b8\", MODE=\"0666\", GROUP=\"plugdev\"" >> /etc/udev/rules.d/51-android.rules'

# Ugly hack to clean up extra kernels after installing updates
grep -q purge-old-kernels ~/.bashrc || ( echo -ne "\n" >> ~/.bashrc; cat << 'PurgeOldKernels' >> ~/.bashrc; echo -ne "\n" >> ~/.bashrc )
sudo() {
    if [[ $1 == "apt-get" ]]; then
        if [[ $2 == "dist-upgrade" || $2 == "upgrade" ]]; then
            command sudo "$@" && sudo purge-old-kernels
        else
            command sudo "$@"
        fi
    else
        command sudo "$@"
    fi
}
PurgeOldKernels

# Get custom fonts
mkdir -p ~/.local/share/fonts
if [ ! -f ~/.local/share/fonts/SourceCodePro-Regular.ttf ]; then
    wget https://github.com/adobe-fonts/source-code-pro/raw/gh-pages/TTF/SourceCodePro-Regular.ttf -O ~/.local/share/fonts/SourceCodePro-Regular.ttf
    fc-cache -fv
fi

# Location-based configuration
if [ "$LOCATION" == "home" ]; then
    # Install packages
    sudo apt -y install gtk-redshift

    # Configure applications to run at start
    ln -s /usr/share/applications/redshift-gtk.desktop ~/.config/autostart/redshift-gtk.desktop

    # Disable daily mlocate update
    sudo chmod -x /etc/cron.daily/mlocate

elif [ "$LOCATION" == "work" ]; then
    # Install packages
    sudo apt -y install language-pack-fr myspell-fr thunderbird thunderbird-locale-fr

    # Install VirtualBox
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian `lsb_release -c | awk '"'"'{print $2}'"'"'` contrib" > /etc/apt/sources.list.d/virtualbox.list'
    sudo apt update
    sudo apt -y install dkms virtualbox-5.0

    # Change Thunderbird language
    cp /usr/share/applications/thunderbird.desktop ~/.local/share/applications/
    sed -i.bak 's/^Exec=thunderbird %u/Exec=env LC_ALL=fr_CA.utf8 thunderbird %u/' ~/.local/share/applications/thunderbird.desktop

    # Configure applications to run at start
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
