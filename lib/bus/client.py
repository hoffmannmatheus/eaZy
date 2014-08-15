import zmq
import json

"""
 Class used by any client of a bus-like architecture peer to get/send data.
"""

defaults = { 
    'host'     : '127.0.0.1',
    'com_port' : 5556,
    'set_port' : 5557,
    'res_port' : 5558
}

context = zmq.Context()

class BusClient:
    def __init__(self, id, filter, opt=defaults):
        self.id       = id
        self.filter   = filter
        self.host     = opt['host']
        self.com_port = opt['com_port']
        self.set_port = opt['set_port']
        self.res_port = opt['res_port']
    
    def setup(self):
        self.context = zmq.Context()
        self.sub_socket = self.context.socket(zmq.SUB)
        if self.filter:
            self.sub_socket.setsockopt(zmq.SUBSCRIBE, self.filter)
        self.sub_socket.connect('tcp://'+self.host+':'+str(self.com_port))
        return self

    def check_income(self, blocking=None):
        raw_data = ''
        try:
            raw_data = self.sub_socket.recv(zmq.NOBLOCK)
        except zmq.error.Again:
            return False
        sender, msg = raw_data.split(' ', 1)
        return json.loads(msg), sender

    def send(self, data, type='send'):
        msg = {'type':type, 'data':data, 'sender':self.id}
        set_socket = self.context.socket(zmq.PAIR)
        set_socket.connect('tcp://'+self.host+':'+str(self.set_port))
        set_socket.send(json.dumps(msg))
        set_socket.close()
        return self

    def get(self, request):
        self.send(request, 'get')
        res_socket = self.context.socket(zmq.PAIR)
        res_socket.bind('tcp://'+self.host+':'+str(self.res_port))
        response = res_socket.recv()
        res_socket.close()
        return json.loads(response)['data']

