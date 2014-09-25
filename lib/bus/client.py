import zmq
import json

"""
Class used by the Client entity to communicate to the Server.

The communication channel should be configured using the three ports:
- com_port: Used to receive broadcast messages from the Server entity. 
- set_port: Used to send messages/request data to the Server entity.
- res_port: Used to receive a responce from a Server.
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
        """
        Constructs a new Bus Client instance.
        
        @param id The identification of this Client.
        @param filter The filter (Server id) of messages.
        @param opt An object that contains the configuration for this Bus
        Client. If provided, the default configurations will be set. eg:
        {host="localhost", com_port=1, set_port=2, res_port=3}
        """
        self.id       = id
        self.filter   = filter
        self.host     = opt['host']
        self.com_port = opt['com_port']
        self.set_port = opt['set_port']
        self.res_port = opt['res_port']
    
    def setup(self):
        """
        Prepares this Bus Server to be used. Before sending/receiving messages,
        the method setup() should be called to properly setup the socket
        configurations.
        """
        self.context = zmq.Context()
        self.sub_socket = self.context.socket(zmq.SUB)
        if self.filter:
            self.sub_socket.setsockopt(zmq.SUBSCRIBE, self.filter)
        self.sub_socket.connect('tcp://'+self.host+':'+str(self.com_port))
        return self

    def check_income(self, blocking=None):
        """
        Receives a message from the communication channel's Server. Tryies to
        get a message from the communication channel, checking the 'com_port'
        for broadcast messages from the Server.

        @param blocking If false, the method will check if there is a message
        and then retrun the message, if it exists, or 'nil' if no message was
        received.  If true, the method will block the interpreter until a new
        message arrives, which then is returned.
        """
        raw_data = ''
        try:
            raw_data = self.sub_socket.recv(zmq.NOBLOCK)
        except zmq.error.Again:
            return False
        sender, msg = raw_data.split(' ', 1)
        return json.loads(msg), sender

    def send(self, data, type='send'):
        """
        Send a message to the Server. Send the given message to the Server of
        this communication channel, using the 'set_port'.
        
        @param msg An object or string containing the message.
        """
        msg = {'type':type, 'data':data, 'sender':self.id}
        set_socket = self.context.socket(zmq.PAIR)
        set_socket.connect('tcp://'+self.host+':'+str(self.set_port))
        set_socket.send(json.dumps(msg))
        set_socket.close()
        return self

    def get(self, request):
        """
        Make a request for the Server. When called, a message is sent to the
        Server indicating this Client has made a request. The Client will stay
        blocked until the response from the Server is received on the
        'res_port', and then returned.

        @param request A string indicating the request (eg. 'device_list')
        """
        self.send(request, 'get')
        res_socket = self.context.socket(zmq.PAIR)
        res_socket.bind('tcp://'+self.host+':'+str(self.res_port))
        response = res_socket.recv()
        res_socket.close()
        return json.loads(response)['data']

