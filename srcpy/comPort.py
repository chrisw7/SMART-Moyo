import serial
import io

def openSerial(port, baud):
    ser = serial.Serial()

    ser.port = port
    ser.baudrate = baud
    ser.open()

    if ser.isOpen():
         print(ser.name + ' is open')
    else:
        print("Port is not open")
        ser.close()
        exit()

    return


def readSerial(port, byte):
    ser = serial.Serial(port)
    data = ser.read(byte).decode("utf-8").replace("\r\n","")

    return data

def fixByteSize(byte, data):
#TODO
    return
