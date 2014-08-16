
mock_list = [
    {
    "id":1,
    "type":"appliance",
    "state": "on",
    "consumption_current":4.2,
    "consumption_accumulated":23.1
    },
    {
    'id':2,
    'type':"appliance",
    'state': "off",
    'consumption_current':0.2,
    'consumption_accumulated':23.1
    },
    {
    'id':3,
    'type':"presencesensor",
    'state': "off"
    },
    {
    'id':4,
    'type':"light",
    'state': "on",
    'consumption_current':2.1,
    'consumption_accumulated':19.4
    },
    {
    'id':5,
    'type':"thermometer",
    'state': "on",
    'value': 23.6
    }
]

import logging
try:
    from client import BusClient
except ImportError:
    print('WARNING: Please set PYTHONPATH correcly. See readme for more info.')


running = True
logging.basicConfig(level=logging.DEBUG)

home_stack = BusClient('device_controller', 'home_stack')
home_stack.setup()

def onHomeStackMessage(msg):
    logging.info('Message: from,type,data', extra=msg)
    if msg['type'] == 'get':
        if msg['data'] == 'devicelist':
            # TODO use real devices
            home_stack.send(mock_list, 'response')
    elif msg['type'] == 'send':
        device_id = msg['data']['id']
        action = msg['data']['action']
        state = msg['data']['state']
        if action == 'setstate':
            print('New state of ' + str(device_id) + ' is ' + state)


def lifeLoop():
    msg = home_stack.check_income()
    if msg:
        onHomeStackMessage(msg[0]);

logging.info('Running ...')
while running:
    lifeLoop()
logging.info('Stopped.')

