#/bin/bash

if [ "$#" == 0 ]; then
    echo 'USAGE: ./build.sh [APP]'; exit 1;
fi

app=$1

pushd . > /dev/null
cd ../
arm-linux-gnueabihf-g++ dev/apps/$app/*.cpp -o output/$app.o
popd > /dev/null

