import serial
#from time import sleep

ser = serial.Serial ("/dev/ttyUSB0", 19200)    #Open port with baud rate

import sys

path = sys.argv[1]

with open(path, 'rb') as f: 
    while (b := f.read(1)):
        print(hex(int.from_bytes(b, 'little')))
        ser.write(b)
    ser.write(0xFF.to_bytes(1,'little'))
    ser.write(0x07.to_bytes(1,'little'))
