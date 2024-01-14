#!/bin/bash
#
sudo apt install cinnamon-desktop-environment -y
sudo apt install git freeglut3-dev libasound2-dev libncurses-dev \
chromium-browser sqlite3 libsqlite3-dev ntp ntpstat iptables \
libgtk-3-dev deepin-icon-theme build-essential cmake autotools-dev debconf-utils \
libsamplerate0-dev libxft-dev libfltk1.1-dev libsndfile1-dev libportaudio2 \
portaudio19-dev build-dep -y
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
# WSJTX install
cd
wget https://wsjt.sourceforge.io/downloads/wsjtx_2.6.1_arm64.deb
sudo dpkg -i wsjtx_2.6.1_arm64.deb
sudo apt install wsjtx-data -y
cd sbitx-on-64bit
cp WSJT-X.ini /home/pi/.config
cd
unzip -o sbitx-on-64-bit/pi.zip
#mkdir fldigi
cd fldigi
sudo sed -i 's/#deb/deb/g' /etc/apt/sources.list
sudo apt-get install aptitude -y
sudo aptitude update
#sudo aptitude build-dep fldigi
sudo apt-get update
sudo apt-get build-dep fldigi -y
#wget http://www.w1hkj.com/alpha/fldigi/fldigi-4.2.03.14.tar.gz
#tar -zxvf fldigi-4.2.03.14.tar.gz
#
unzip -o /home/pi/sbitx-on-64-bit/fldigi-4.1.20.zip
unzip -o /home/pi/sbitx-on-64-bit/flrig-1.4.5.zip
unzip -o /home/pi/sbitx-on-64-bit/hamlib-4.4.zip
#
#
cd fldigi-4.1.20
# Fix CFLAGS -remove 3dnow and sse options which arenot vaild on arm64
sudo sed -i 's/-mno-3dnow//g' configure
sudo sed -i 's/-mfpmath=sse//g' configure
./configure --enable-optimizations=native
make
sudo make install
cd
cd fldigi/flrig-1.4.5
sudo sed -i 's/-mno-3dnow//g' configure
sudo sed -i 's/-mfpmath=sse//g' configure
./configure --enable-optimizations=native
make
sudo make install
cd
cd fldigi/hamlib-4.4
./configure
make
sudo make install
sudo ldconfig
cd
cd sbitx
./build sbitx
cd
cp sbitx-on-64-bit/sBitx.desktop /home/pi/Desktop
echo "Done installing!"
echo "run sudo raspi-config and under System Options > Boot / Auto Login, select Desktop Autologin as 'pi' and reboot"
echo "Don't forget to copy your sbitx/data files from your SD card to the /home/ip/sbits directory!"
exit




