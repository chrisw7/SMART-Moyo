import io
import glob
import serial
import sys


""" Lists serial port names

    :raises EnvironmentError:
        On unsupported or unknown platforms
    :returns:
        A list of the serial ports available on the system
"""
def serial_ports():

    if sys.platform.startswith('win'):
        ports = ['COM%s' % (i + 1) for i in range(256)]
    elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
        # this excludes your current terminal "/dev/tty"
        ports = glob.glob('/dev/tty[A-Za-z]*')
    elif sys.platform.startswith('darwin'):
        ports = glob.glob('/dev/tty.*')
    else:
        raise EnvironmentError('Unsupported platform')

    result = []
    for port in ports:
        try:
            s = serial.Serial(port)
            s.close()
            result.append(port)
        except (OSError, serial.SerialException):
            pass
    return result[0]


#Checks for idle accelerometer (No compressions being performed)
def idle(accel, err):
    tmp = max(accel) - min(accel)
    if abs(tmp) <= 0.09*err:
        print("Accelerometer is idle")
        return True

    return False

#Opens up manual serial port
def openSerial(port, baud):
    ser = serial.Serial(port, baud)

    if ser.isOpen():
        print('Port ' + ser.name + ' is open')
    else:
        print("Port is not open")
        ser.close()
        exit()

    return

#Reads one line from the serial port
def readSerial(port, byte):
    ser = serial.Serial(port)
    data = ser.read(byte).decode("utf-8")
    return data

def openBluetooth(port, baud):
    ser = serial.Serial()

    ser = serial
    ser.port = port
    ser.baudrate = baud

    ser.open

    if ser.isOpen():
         print(ser.name + ' is open')
    else:
        print("Port is not open")
        ser.close()
        exit()
    return


def readBluetooth():
    ser = serial.Serial(port)
    data = ser.read(byte).decode("utf-8").replace("\r\n","")
    return

#Fixes each line as time becomes large
def fixByteSize(byte, data):
#TODO
    return
