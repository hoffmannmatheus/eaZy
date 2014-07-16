import thread
import sys
import zmq
import time

context = zmq.Context()

def subscriber():
    sub_socket = context.socket(zmq.SUB)
    sub_socket.connect ("tcp://localhost:%s" % "5556")
    topicfilter = "10001"
    sub_socket.setsockopt(zmq.SUBSCRIBE, topicfilter)
    while True:
        string = sub_socket.recv()
        topic, messagedata = string.split()
        print topic, messagedata
try:
    thread.start_new_thread(subscriber, ())
except:
    print "Error: unable to start thread"

print 'yay.'


for n in range (50):
    time.sleep(0.25)
    pair_socket = context.socket(zmq.PAIR)
    pair_socket.connect("tcp://localhost:%s" % "5555")
    pair_socket.send("test"+sys.argv[1])
    pair_socket.close()

# todo:
# pass JSON!
# make as a lib customizable
