echo "Running eaZy!"
# Checking if the paths are set
if [ -z "$PYTHONPATH" ]; then 
    echo "Please export environment variable PYTHONPATH. Example:"
    echo 'export PYTHONPATH=$PYTHONPATH:$EAZYPATH/lib/bus/'
    exit 1
fi
# Getting IP
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | 
        grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
# Initiating eaZy components
node apps/ui/eazy_web/app.js &> /dev/null &
lua apps/home_stack/home_stack.lua &> /dev/null &
sudo python apps/device_controller/device_controller.py &> /dev/null &
echo ""
echo "All apps are running. Give about 5 minutes for all systems"
echo "to be available, as ZWave takes some time to be ready."
echo ""
echo "Address: http://eazy.local:3000 or http://$myip:3000"
