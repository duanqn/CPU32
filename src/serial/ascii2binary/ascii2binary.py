import sys
import os
import binascii

ascii_file = open('C:\\Sites\\CPU32\\ucore\\Fibo_flash.mem', 'r')
binary_file = open('C:\\Sites\\CPU32\\ucore\\Fibo_flash', 'wb')
buffer2 = ascii_file.read()
binary2 = binascii.b2a_hex(buffer2)
binary_file.write(binary2)
binary_file.close()
ascii_file.close()
