import serial
import os
import time
import sys
import struct

ser = serial.Serial(port = 'COM7', baudrate = 115200, bytesize = 8, parity = 'N', stopbits = 1, timeout = None)
binary = open('d:\\MyProgram\\test2.dat','rb')
binary1 = binary.read(2)
while (not binary1 == "" and ser.isOpen()):
    print binary1
    stt = bytes("122448")
    ser.write(binary1)
    time.sleep(1)
    binary1 = binary.read(2)
binary.close()
