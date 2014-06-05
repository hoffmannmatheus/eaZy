#/bin/bash

# Help from:
# http://hertaville.com/2012/09/28/development-environment-raspberry-pi-cross-compiler/

root='..'
pushd . > /dev/null

# build 
sudo apt-get -qy install build-essential
# 64bits? : sudo apt-get -qy install ia32-libs

# r-pi arm compiler
cd $root/third/
mkdir -p rpi && cd rpi
git clone git://github.com/raspberrypi/tools.git

# export compiler path
echo ''
echo 'NOTE! Please add this (adjusting path) to your  ~/.bashrc and apply "source ~/.bashrc"'
echo 'eg.'
echo 'PATH=$PATH:$HOME/projects/eaZy/third/rpi/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin'

# done
popd > /dev/null
