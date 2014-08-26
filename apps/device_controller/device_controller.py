
import logging
try:
    from client import BusClient
except ImportError:
    print('WARNING: Please set PYTHONPATH correcly. See readme for more info.')

from zwave_controller import ZWaveController

running = True
logging.basicConfig(level=logging.DEBUG)

def lifeLoop():
    msg = home_stack.check_income()
    if msg:
        onHomeStackMessage(msg[0]);

def onHomeStackMessage(msg):
    logging.info('Message: from,type,data', extra=msg)
    if msg['type'] == 'get':
        if msg['data'] == 'devicelist':
            devicelist = zwave.getDeviceList()
            home_stack.send(devicelist, 'response')
    elif msg['type'] == 'send':
        id_device = msg['data']['id']
        mtype = msg['data']['type']
        state = msg['data']['state']
        if mtype == 'setstate':
            zwave.setDeviceState(id_device, state)
            print('New state of ' + str(id_device) + ' is ' + state)

def onDeviceUpdate(device):
    print('will send notifycation!')
    msg = {'type':'update','data':device,'id_device':device['id_device']}
    home_stack.send(msg, 'send')

home_stack = BusClient('device_controller', 'home_stack')
home_stack.setup()

zwave = ZWaveController()
zwave.setup(onDeviceUpdate)

logging.info('Running ...')
while running:
    lifeLoop()
logging.info('Stopped.')

