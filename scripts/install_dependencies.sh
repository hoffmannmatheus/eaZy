#############################
# Dependencies Installation #
###    for Raspbian     #####
#
#
# First, on /etc/sudoers, add:
# > Defaults env_keep += "PYTHONPATH"
mkdir -p ~/software
# Zero MQ
sudo apt-get install uuid-dev libtool autoconf automake -y
cd ~/software/
wget http://download.zeromq.org/zeromq-3.2.4.tar.gz
tar xvfz zeromq-3.2.4.tar.gz
cd zeromq-3.2.4
./configure
make
sudo make install
# Installing Python ZMQ binding
cd ~/software/
wget http://pypi.python.org/packages/source/C/Cython/Cython-0.16.tar.gz
tar xvfz Cython-0.16.tar.gz
cd Cython-0.16
sudo python setup.py install
cd ~/software/
git clone git://github.com/zeromq/pyzmq.git
cd pyzmq
./setup.py configure 
sudo ./setup.py install
# or sudo pip install pyzmq
# SQLite3
sudo apt-get install sqlite3 -y
sudo apt-get install libsqlite3-dev -y
# Lua dependencies: luarocks, lua-sqlite3, luajson,
sudo apt-get install luarocks -y
sudo luarocks install luajson
sudo luarocks install lsqlite3
sudo luarocks install lzmq  # requires zmq 3.2.4
# Add new line: /usr/local/lib:
# > sudo vi /etc/ld.so.conf
# > sudo ldconfig
# Python Open ZWave + dependencies. Note: needs cython v0.14
cd ~/software
sudo apt-get install python-pip python-dev -y
sudo pip install cython==0.14
sudo apt-get install python-dev python-setuptools python-louie -y
sudo apt-get install build-essential libudev-dev g++ make -y
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
cd ~/eaZy/apps/ui/eazy_web/
sudo npm install

