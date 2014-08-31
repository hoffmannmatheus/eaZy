#/bin/bash

echo ''
echo 'Deploying to pi@eazy:/home/pi/eaZy/'
echo 'Node: you will be prompted for your Raspberry Pi password several times...'
echo ''

HOST="eazy.local" # Default for RPi is 'raspberrypi.local'

pushd . > /dev/null

echo 'Backing up old files (if any)...'
ssh pi@$HOST "mkdir -p ~/tmp/ && rm -rf ~/tmp/eaZy_backup && mv ~/eaZy ~/tmp/eaZy_backup && mkdir -p ~/eaZy"
echo 'Installing new files...'
scp -r ../* pi@$HOST:~/eaZy
echo 'Installing dependencies....  Oh boy, this can take a while. Maybe some coffee?'
ssh pi@$HOST "cd ~/eaZy/ && mv scripts/eaZy.sh . && cd ~/eaZy/apps/ui/eazy_web && rm -rf node_modules && npm install"


popd > /dev/null
