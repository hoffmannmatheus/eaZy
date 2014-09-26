#############################
# Dependencies Installation #
###    for Raspbian     #####
#
#
# First, on /etc/sudoers, add:
# > Defaults env_keep += "PYTHONPATH"
mkdir -p ~/software
# Zero MQ
sudo apt-get install uuid-dev libtool autoconf automake
cd ~/software/
wget http://download.zeromq.org/zeromq-3.2.4.tar.gz
tar xvfz zeromq-3.2.4.tar.gz
cd zeromq-3.2.4
./configure
make
sudo make install
Installing Python ZMQ binding
cd ~/software/
wget http://pypi.python.org/packages/source/C/Cython/Cython-0.16.tar.gz
sudo python setup.py install
git clone git://github.com/zeromq/pyzmq.git
cd pyzmq
./setup.py configure 
sudo ./setup.py install
# or sudo pip install pyzmq
# SQLite3
sudo apt-get install sqlite3
# Lua dependencies: luarocks, lua-sqlite3, luajson,
sudo apt-get install luarocks
sudo luarocks install luajson
sudo apt-get install libsqlite3-dev
sudo luarocks install lsqlite3
# Installing Lua ZMQ binding
# (needs zmq 3.2.4)
sudo luarocks install lzmq
# Add new line: /usr/local/lib:
# > sudo vi /etc/ld.so.conf
# > sudo ldconfig
# Python Open ZWave + dependencies. Note: needs cython v0.14
cd ~/software
sudo apt-get install python-pip python-dev
sudo pip install cython==0.14
sudo apt-get install python-dev python-setuptools python-louie
sudo apt-get install build-essential libudev-dev g++ make
wget http://bibi21000.no-ip.biz/python-openzwave/python-openzwave-0.2.6.tgz
tar -zxvf python-openzwave-0.2.6.tgz
cd python-openzwave-0.2.6
mv openzwave packed_openzwave
# download and compile OpenZWave
wget http://www.openzwave.com/downloads/openzwave-1.0.791.tar.gz
tar -zxvf openzwave-1.0.791.tar.gz
mv openzwave-1.0.791 openzwave
cd openzwave
make
sudo make install
cd ..
# compile Python OpenZWave
./compile.sh
sudo ./install.sh
Node.js
# Node.js
wget http://node-arm.herokuapp.com/node_latest_armhf.deb 
sudo dpkg -i node_latest_armhf.deb

