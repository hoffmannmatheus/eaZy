#/bin/bash
echo ''
echo 'Deploying to pi@eazy:/home/pi/eaZy/'
echo ''
HOST="eazy.local" # Default for RPi is 'raspberrypi.local'
echo "checking host $HOST..."
ping -q -w 5 $HOST
if [ $? -ne 0 ]; then 
    echo "error!! problem accessing host."
    exit 1;
fi
echo " done."
echo 'Backing up old files (if any)...'
ssh pi@$HOST "mkdir -p ~/tmp/ && rm -rf ~/tmp/eaZy_backup
              && mv ~/eaZy ~/tmp/eaZy_backup && mkdir -p ~/eaZy"
echo ' done.'
echo 'Installing new files...'
scp -r ../* pi@$HOST:~/eaZy
echo ' done.'
echo 'Installing dependencies... Oh boy, this can take a while. Maybe some coffee?'
ssh pi@$HOST "cd ~/eaZy/ && mv scripts/eaZy.sh . 
              && cd ~/eaZy/apps/ui/eazy_web
              && rm -rf node_modules && npm install"
echo ' done.'
exit 0;
