#/bin/bash

echo 'deploying to pi@raspberrypi.local:/home/pi/software/eaZy/'

pushd . > /dev/null
cd ../
scp output/* pi@raspberrypi.local:/home/pi/software/eaZy/
popd > /dev/null
