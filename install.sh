#!/bin/bash
LOG_FILE=install.txt
#{ 
echo "----------------------------------------------"
echo "This will take about 45 minutes to complete."
echo "----------------------------------------------"
DIR="/home/pi/sbitx-on-64-bit/fftw-3.3.10"
# Update and install OS
sudo apt update -y
sudo apt upgrade -y
# Install Cinnamon desktop
sudo apt install cinnamon-desktop-environment -y
# Install some depandant packages and apps
sudo apt install git freeglut3-dev libasound2-dev libncurses-dev \
chromium-browser sqlite3 libsqlite3-dev ntp ntpstat iptables \
libgtk-3-dev deepin-icon-theme build-essential cmake autotools-dev debconf-utils \
libsamplerate0-dev libxft-dev libfltk1.1-dev libsndfile1-dev libportaudio2 \
portaudio19-dev iptables wsjtx wsjtx-data wsjtx-doc fldigi \
libhamlib-* deepin-icon-theme deepin-terminal nemo-python bibata-cursor-theme -y
#
sudo raspi-config nonint do_boot_behaviour B4
sudo cd /home
# pi's preconfigured desktop
sudo tar-zxvf /home/pi/sbitx-on-64-bit/pi.tgz
#sudo cp sbitx-on-64-bit/lightdm-autologin-greeter.conf /etc/lightdm/lightdm.conf.d/
# install some background images and Pi's .config settings 
cd
unzip -o sbitx-on-64-bit/Backgrounds
# Install Farhan's sbitx software from github'
git clone https://github.com/afarhan/sbitx.git
# Follow Farhan's install.txt instructions'
grep "modprobe snd-aloop" /etc/rc.local
if [ $? -eq 1 ]
 then sudo sed -i '13 i modprobe snd-aloop enable=1,1,1 index=1,2,3' /etc/rc.local
fi
#fi
echo sudo modprobe snd-aloop enable=1,1,1 index=1,2,3 
#copy boot setup config file to /boot
sudo cp sbitx-on-64-bit/config.txt /boot
# Fix sbitx/ft8_lib/Makefile
cd sbitx/ft8_lib
sed -i 's/-std=c11/-std=c++0x/g' Makefile
make
sudo make install
# Install my version of WiringPi for ARM64
cd 
cd sbitx-on-64-bit
tar -zxvf WiringPi-arm64.tgz
cd WiringPi-arm64
./build
# Test if working
gpio readall
sleep 10
cd
cd sbitx-on-64-bit
# Compile fftw only if directory doesn't already exist
if [ ! -d "$DIR" ]; then
        tar -zxvf fftw-3.3.10.tar.gz
        cd fftw-3.3.10
        ./configure
        make
        sudo make install
        ./configure --enable-float
        make
        sudo make install
fi
#
grep "; autospawn = yes" /etc/pulse/client.conf
if [ $? -eq 0 ]
    then sudo sed -i 's/; autospawn = yes/autospawn = no/g' /etc/pulse/client.conf
fi
# Make available the compiled libs  
sudo ldconfig
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
# Copy hostname & host files to /etc if custom imager settings weren't used' 
cd
cd sbitx
sudo cp hosts /etc/hosts
sudo cp hostname /etc/hostname
cd
sudo ldconfig
cd sbitx
./build sbitx
cd /home
tar -zxvf ~/sbitx-on-64-bit/pi.tgz
cd
echo "Done installing!"
echo "Don't forget to copy your sbitx/data files from your SD card to the /home/ip/sbits directory!"
IFS=''
echo -e "Press [ESC] to exit..."
echo -e "Press [ENTER] to reboot..."
for (( i=120; i>0; i--)); do

printf "\rRebooting in $i seconds..."
read -s -N 1 -t 1 key

if [ "$key" = $'\e' ]; then
        echo -e "\n [ESC] Pressed"
        exit
elif [ "$key" == $'\x0a' ] ;then
        echo -e "\n [Enter] Pressed"
        break
fi
done
sudo reboot
exit
#} 2>&1 | tee -- "$LOG_FILE"

