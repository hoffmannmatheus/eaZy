import thread
import sys
import zmq
import time

context = zmq.Context()

pub_socket = context.socket(zmq.PUB)
pub_socket.bind("tcp://*:%s" % "5556")
topicfilter = "10001"

pair_socket = context.socket(zmq.PAIR)
pair_socket.bind("tcp://*:%s" % "5555")

while True:
    msg = pair_socket.recv()
    print 'got ' + msg
    pub_socket.send("%s %s" % (topicfilter, msg))
