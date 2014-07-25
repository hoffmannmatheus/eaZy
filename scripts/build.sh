#/bin/bash

if [ "$#" == 0 ]; then
    echo 'USAGE: ./build.sh <app_name> [target=arm,x86]'; exit 1;
fi

app=$1
if [ $# -gt 1 ]; then
    target=$2
else
    target="arm"
fi


pushd . > /dev/null
cd ../
if [ ! -e apps/$app ]; then
    echo "Error: App '$app' not found."; exit 1;
fi
if [ $target == "x86" ]; then
    g++ apps/$app/*.cpp -o output/$app.o
elif [ $target == "arm" ]; then
    arm-linux-gnueabihf-g++ apps/$app/*.cpp -o output/$app.o
fi
popd > /dev/null

