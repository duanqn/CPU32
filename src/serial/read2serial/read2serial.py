import serial
import os
import time
import sys
import struct

ser = serial.Serial(port = 'COM7', baudrate = 115200, bytesize = 8, parity = 'N', stopbits = 1, timeout = None)
binary = open('c:\\Sites\\CPU32\\ucore\\ucore_kernel_r1.elf', 'wb')
while (ser.isOpen()):
    binary1bytes = ser.read(1)

    print binary1bytes.encode("hex")
    binary.write(binary1bytes)
binary.close()
print "read finished"
