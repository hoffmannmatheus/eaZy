
echo "Running eaZy!"

if [ -z "$PYTHONPATH" ]; then 
    echo "Please export environment variable PYTHONPATH. Example:"
    echo 'export PYTHONPATH=$PYTHONPATH:$EAZYPATH/lib/bus/'
    exit 1
fi

node apps/ui/eazy_web/app.js &> /dev/null &
lua apps/home_stack/home_stack.lua &> /dev/null &
sudo python apps/device_controller/device_controller.py &> /dev/null &

echo "All apps are running. Give about 5 minutes for all systems to be available, as ZWave takes some time to be ready."
echo "Address: http://eazy.local:3000"
