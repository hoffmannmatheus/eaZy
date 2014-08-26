
import sys, os

import openzwave
from openzwave.node import ZWaveNode
from openzwave.value import ZWaveValue
from openzwave.scene import ZWaveScene
from openzwave.controller import ZWaveController
from openzwave.network import ZWaveNetwork
from openzwave.option import ZWaveOption
from louie import dispatcher, All
from threading import Timer


class ZWaveController():
    network = None

    def setup(self, updateCallback):
        dispatcher.connect(self.onNetworkReady, ZWaveNetwork.SIGNAL_NETWORK_READY)
        dispatcher.connect(self.onNetworkStart, ZWaveNetwork.SIGNAL_NETWORK_STARTED)
        dispatcher.connect(self.onNetworkFailed, ZWaveNetwork.SIGNAL_NETWORK_FAILED)

        options = ZWaveOption("/dev/ttyUSB0", \
          config_path="/home/matheus/software/python-openzwave-0.2.6/openzwave/config", \
          user_path=".", cmd_line="")
        options.set_append_log_file(False)
        options.set_console_output(False)
        options.set_save_log_level('Debug')
        options.set_poll_interval(30);
        options.set_suppress_value_refresh(False)
        options.addOptionBool("AssumeAwake", True)
        options.set_logging(True)
        options.lock()
        self.network = ZWaveNetwork(options, autostart=False)
        self.onDeviceUpdateCallback = updateCallback
        self.network.start()
        self.addedConnections = False
        Timer(2*60, self.setupConnections).start()


    def tearDown(self):
        network.stop()

    def getDeviceList(self):
        devices = []
        for node in self.network.nodes:
            if node == 1: continue # don't add the controller
            devices.append(self.buildDevice(node))
        return devices

    def buildDevice(self, node):
        dev = {}
        dev['id'] = int(self.network.home_id)*1000 + node
        dev['type'] = 'unknown'
        dev['product_name'] = self.network.nodes[node].product_name
        if self.getValueForLabel(node, 'Switch'):
            dev['type'] = 'appliance'
            dev['consumption_accumulated'] = self.getValueForLabel(node, 'Energy')
            dev['consumption_current'] = self.getValueForLabel(node, 'Power')
            if self.getValueForLabel(node, 'Switch') == 'True':
                dev['state'] = 'on'
            else:
                dev['state'] = 'off'
        if self.getValueForLabel(node, 'Sensor'):
            dev['type'] = 'sensor'
            dev['temperature'] = self.getValueForLabel(node, 'Temperature')
            dev['luminance']   = self.getValueForLabel(node, 'Luminance')
        dev['battery_level'] = self.getValueForLabel(node, 'Battery Level')
        return dev

    def getValueForLabel(self, node, label):
        for v in self.network.nodes[node].values: 
            if self.network.nodes[node].values[v].label == label:
                #self.network.nodes[node].refresh_value(v);
                return str(self.network.nodes[node].values[v].data_as_string)
        return None

    def setDeviceState(self, device_id, state):
        node = device_id%1000
        if not self.network.nodes[node]: return
        for val in self.network.nodes[node].get_switches() :
            self.network.nodes[node].set_switch(val, True if state=='on' else False)
        
    def setupConnections(self):
        self.addedConnections = True
        dispatcher.connect(self.onNodeUpdate, ZWaveNetwork.SIGNAL_NODE)
        dispatcher.connect(self.onNodeUpdateValue, ZWaveNetwork.SIGNAL_VALUE)
        dispatcher.connect(self.onNodeUpdateValue, ZWaveNetwork.SIGNAL_NODE_EVENT)
        dispatcher.connect(self.onNodeUpdateValue, ZWaveNetwork.SIGNAL_VALUE_CHANGED)
        dispatcher.connect(self.onNodeUpdateValue, ZWaveNetwork.SIGNAL_VALUE_REFRESHED)

    # Event Handlers

    def onNetworkStart(self, network):
        print("network started : homeid %0.8x - %d nodes were found." % \
            (network.home_id, network.nodes_count))

    def onNetworkFailed(self, network):
        print("network can't load :(")

    def onNetworkReady(self, network):
        print("network : I'm ready : %d nodes were found." % network.nodes_count)
        print("network : my controller is : %s" % network.controller)
        self.network = network
        if not self.addedConnections:
            self.setupConnections()

    def onNodeUpdate(self, network, node):
        print('node UPDAAAATEEE : %s.' % node)
        self.network = network

    def onNodeUpdateValue(self, network, node, value):
        print('node : %s.' % node)
        print('value: %s.' % value)
        if node.node_id == 1: return # don't send controller notifications
        dev = self.buildDevice(node.node_id)

        if type(value) is int:
            if dev['type'] == 'sensor' and value == 255:
                dev['presence'] = 'detected'
                self.network = network
                self.onDeviceUpdateCallback(dev)

        if type(value) is ZWaveValue:
            if dev['type'] == 'appliance' and value.label == 'Switch':
                state = value.data and 'on'  or 'off'
                dev['state'] = state
                self.network = network
                self.onDeviceUpdateCallback(dev)

            if dev['type'] == 'appliance' and value.label == 'Power':
                power = str(value.data)
                if dev['state'] == 'off' or (dev['state'] == 'on' and float(power) != 0):
                    dev['consumption_current'] = power
                    self.network = network
                    self.onDeviceUpdateCallback(dev)
                else:
                    self.network = network
                    print('WHAATF do i do with this? %s', power)

            if dev['type'] == 'appliance' and value.label == 'Energy':
                energy = str(value.data)
                dev['consumption_accumulated'] = energy
                self.network = network
                self.onDeviceUpdateCallback(dev)

            if dev['type'] == 'sensor' and value.label == 'Temperature':
                temperature = str(value.data)
                dev['temperature'] = temperature
                self.network = network
                self.onDeviceUpdateCallback(dev)

            if dev['type'] == 'sensor' and value.label == 'Luminance':
                luminance = str(value.data)
                dev['luminance'] = luminance 
                self.network = network
                self.onDeviceUpdateCallback(dev)
        
            if value.label == 'Battery Level':
                battery = str(value.data)
                dev['battery_level'] = battery
                self.network = network
                self.onDeviceUpdateCallback(dev)
        
