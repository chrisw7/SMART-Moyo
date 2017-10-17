from time import time as cTime
import calibrate
import comPort
import matplotlib.animation as animation
import msvcrt
import numpy
import spectralAnalysis


#API Key pxkXiGLfWlArewVQM5Nv
#py = plotly.plotly("Username", "API-Key").

compressionresetTime = 2
txyz = 3 #Z index

port = "COM5"
baud = 2400
byte = 26  #208 bits
#seconds =2400/208 = 11.5
print("Using COM5 as default, and baudrate of ", baud)

comPort.openSerial(port, baud)

print("Calibrating accelerometer")
print("DO NOT MOVE")

data = [];
for i in range(0, 39):
    rawData = comPort.readSerial(port, byte)
    rawArray = calibrate.formatData(rawData)
    data.append(rawArray)

data = numpy.array(data)
accel = data[:, txyz]

offset = calibrate.offsetAccel(accel, numpy)

GRAVITY = 9.80665
accel = (accel[:] - offset)

if accel.all() == False:
    print("You moved it. Restart the process")
    exit()

print("Calibrated. \nBegin Compressions")
print(offset)


while True:

    data, sTime, accel = [], [], []

    currentTime = int(cTime())
    endTime = currentTime + compressionresetTime

    while currentTime < endTime:
        currentTime = int(cTime())

        rawData = comPort.readSerial(port, byte)
        rawArray = calibrate.formatData(rawData)

        data.append(rawArray)
        data = numpy.array(data)

        sTime = data[:, 0]
        accel = data[:, txyz]

        sTime = calibrate.scaleTime(sTime)

        accel = (accel[:] - offset)*GRAVITY

        data = data.tolist()

    #Call fft here
    if (comPort.idle(accel, 1.5)):
        continue
    [sofT, fcc] = spectralAnalysis.calculations(sTime, accel, numpy)
#def plot(x, y, xlbl, ylbl, title, subplt):
    #graph.plot(sTime, sofT, "Time (s)", "Displacement", "Distance vs Time", 111)
