import serial
import io

def idle(accel, err):
    tmp = max(accel) - min(accel)
    if abs(tmp) <= 0.09*err:
        print("Accelerometer is idle")
        return True

    return False


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
