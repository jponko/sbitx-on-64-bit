#!/bin/bash
sudo apt install cinnamon-desktop-environment -y
#
sudo apt install git freeglut3-dev libasound2-dev libncurses-dev \
chromium-browser sqlite3 libsqlite3-dev ntp ntpstat iptables \
libgtk-3-dev deepin-icon-theme build-essential cmake autotools-dev debconf-utils \
libsamplerate0-dev libxft-dev libfltk1.1-dev libsndfile1-dev libportaudio2 \
portaudio19-dev iptables wsjtx wsjtx-data wsjtx-doc fldigi \
libhamlib-* -y
cd 
git clone https://github.com/afarhan/sbitx.git
#
grep "modprobe snd-aloop" /etc/rc.local
if [ $? -eq 1 ]
 then sudo sed -i '13 i modprobe snd-aloop enable=1,1,1 index=1,2,3' /etc/rc.local
fi
#fi
echo sudo modprobe snd-aloop enable=1,1,1 index=1,2,3 
#copy boot setup config file to /boot
sudo cp sbitx-on-64-bit/config.txt /boot
#fix sbitx/ft8_lib/Makefile
cd sbitx/ft8_lib
sed -i 's/-std=c11/-std=c++0x/g' Makefile
make
sudo make install
cd 
cd sbitx-on-64-bit
tar -zxvf WiringPi-arm64.tgz
cd WiringPi-arm64
./build
gpio readall
cd
cd sbitx-on-64-bit
tar -zxvf fftw-3.3.10.tar.gz
cd fftw-3.3.10
./configure
make
sudo make install
./configure --enable-float
make
sudo make install
grep "; autospawn = yes" /etc/pulse/client.conf
if [ $? -eq 0 ]
    then sudo sed -i 's/; autospawn = yes/autospawn = no/g' /etc/pulse/client.conf
fi
sudo ldconfig
#enable loopback now
sudo modprobe snd-aloop enable=1,1,1 index=1,2,3
# Setup iptables
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
sudo iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 8080
sudo iptables-save -f /etc/iptables/rules.v4
sudo ip6tables-save -f /etc/iptables/rules.v6
sudo debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
sudo apt-get -y install iptables-persistent
# Set hostname & host files
cd
cd sbitx
sudo cp hosts /etc/hosts
sudo cp hostname /etc/hostname
#
cd sbitx-on-64bit
cp WSJT-X.ini /home/pi/.config
cd
unzip -o sbitx-on-64-bit/pi.zip
sudo ldconfig
cd
cd sbitx
./build sbitx
cd
mkdir Desktop
cp sbitx/sBitx.desktop ../Desktop
echo "Done installing!"
echo "run sudo raspi-config and under System Options > Boot / Auto Login, select Desktop Autologin as 'pi' and reboot"
echo "Don't forget to copy your sbitx/data files from your SD card to the /home/ip/sbits directory!"
exit




