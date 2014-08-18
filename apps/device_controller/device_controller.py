
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
        device_id = msg['data']['id']
        action = msg['data']['action']
        state = msg['data']['state']
        if action == 'setstate':
            zwave.setDeviceState(device_id, state)
            print('New state of ' + str(device_id) + ' is ' + state)

def onDeviceUpdate(device):
    print('will send notifycation!')
    msg = {'type':'update','data':device,'id':device['id']}
    home_stack.send(msg, 'send')

home_stack = BusClient('device_controller', 'home_stack')
home_stack.setup()

zwave = ZWaveController()
zwave.setup(onDeviceUpdate)

logging.info('Running ...')
while running:
    lifeLoop()
logging.info('Stopped.')

