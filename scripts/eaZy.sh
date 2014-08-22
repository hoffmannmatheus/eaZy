
echo "Running eaZy!"
cd ~/eaZy/

export EAZYPATH=/home/pi/eaZy/
export PYTHONPATH=$PYTHONPATH:$EAZYPATH/lib/bus/

sudo su
sudo python apps/device_controller/device_controller.py &> /dev/null &
lua apps/home_stack/home_stack.lua &> /dev/null &
node apps/ui/eazy_web/app.js &> /dev/null &

echo "All apps are running. Give about 5 minutes for all systems to be available, as ZWave takes some time to be ready."
