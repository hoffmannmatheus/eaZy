
import sys, os

import openzwave
from openzwave.node import ZWaveNode
from openzwave.value import ZWaveValue
from openzwave.scene import ZWaveScene
from openzwave.controller import ZWaveController
from openzwave.network import ZWaveNetwork
from openzwave.option import ZWaveOption
from louie import dispatcher, All


class ZWaveController():
    network = None

    def setup(self):
        dispatcher.connect(self.onNetworkReady, ZWaveNetwork.SIGNAL_NETWORK_READY)
        dispatcher.connect(self.onNetworkStart, ZWaveNetwork.SIGNAL_NETWORK_STARTED)
        dispatcher.connect(self.onNetworkFailed, ZWaveNetwork.SIGNAL_NETWORK_FAILED)

        options = ZWaveOption("/dev/ttyUSB0", \
          config_path="/home/matheus/software/python-openzwave-0.2.6/openzwave/config", \
          user_path=".", cmd_line="")
        options.set_append_log_file(False)
        options.set_console_output(False)
        options.set_save_log_level('Debug')
        options.set_logging(True)
        options.lock()
        self.network = ZWaveNetwork(options, autostart=False)
        self.network.start()

    def tearDown(self):
        network.stop()

    def getDeviceList(self):
        devices = []
        for node in self.network.nodes:
            if node == 1: continue # don't add the controller
            dev = {}
            dev['id'] = node
            
            if self.getValueForLabel(node, 'Switch'):
                dev['type'] = 'appliance'
                dev['product_name'] = self.network.nodes[node].product_name
                dev['consumption_accumulated'] = self.getValueForLabel(node, 'Energy')
                dev['consumption_current'] = self.getValueForLabel(node, 'Power')
                if self.getValueForLabel(node, 'Switch') == 'True':
                    dev['state'] = 'on'
                else:
                    dev['state'] = 'off'

            if self.getValueForLabel(node, 'Sensor'):
                dev['type'] = 'sensor'
                dev['product_name'] = self.network.nodes[node].product_name
                dev['temperature'] = self.getValueForLabel(node, 'Temperature')
                dev['luminance']   = self.getValueForLabel(node, 'Luminance')
                if self.getValueForLabel(node, 'Sensor') == 'True':
                    dev['presence'] = 'on'
                else:
                    dev['presence'] = 'off'

            devices.append(dev)
        return devices

    def getValueForLabel(self, node, label):
        for v in self.network.nodes[node].values: 
            if self.network.nodes[node].values[v].label == label:
                return str(self.network.nodes[node].values[v].data_as_string)
        return None

    def setDeviceState(self, node, state):
        if not self.network.nodes[node]: return
        for val in self.network.nodes[node].get_switches() :
            self.network.nodes[node].set_switch(val, True if state=='on' else False)
        

    # Event Handlers

    def onNetworkStart(self, network):
        print("network started : homeid %0.8x - %d nodes were found." % \
            (network.home_id, network.nodes_count))

    def onNetworkFailed(self, network):
        print("network can't load :(")

    def onNetworkReady(self, network):
        print("network : I'm ready : %d nodes were found." % network.nodes_count)
        print("network : my controller is : %s" % network.controller)
        dispatcher.connect(self.onNodeUpdate, ZWaveNetwork.SIGNAL_NODE)
        dispatcher.connect(self.onNodeUpdate, ZWaveNetwork.SIGNAL_VALUE)

    def onNodeUpdate(self, network, node):
        print('node : %s.' % node)
        self.network = network
        
