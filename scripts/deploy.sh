#/bin/bash

echo ''
echo 'Deploying to pi@raspberrypi.local:/home/pi/eaZy/'
echo 'Node: you will be prompted for your Raspberry Pi password several times...'
echo ''

pushd . > /dev/null

echo 'Backing up old files (if any)...'
ssh pi@raspberrypi.local "mkdir -p ~/tmp/ && rm -rf ~/tmp/eaZy_backup && mv ~/eaZy ~/tmp/eaZy_backup && mkdir -p ~/eaZy"
echo 'Installing new files...'
scp -r ../* pi@raspberrypi.local:~/eaZy
echo 'Installing dependencies....  Oh boy, this can take a while. Maybe some coffee?'
ssh pi@raspberrypi.local "cd ~/eaZy/ && mv scripts/eaZy.sh . && cd ~/eaZy/apps/ui/eazy_web && rm -rf node_modules && npm install"


popd > /dev/null
