from time import time as cTime
import calibrate
import comPort
import feedback
import matplotlib.animation as animation
import numpy
import spectralAnalysis
import sys

#Official recommended ranges for CPR rate (cpm) and depth (cm)
#Adjusts depending on age of person (adult, youth, child, infant)
minDepth, maxDepth, depthTolerance = calibrate.age(sys.argv[0])
minRate, maxRate, rateTolerance = 100, 120, 5

GRAVITY = 9.80665

compressionresetTime = 2
txyz = 3 #Z index

port = "COM5"
#seconds = 2400 bps / 208 bits = 11.5 /second
baud = 2400
byte = 26  #208 bits
print("Using " + str(port) + " as default, and baudrate of " + str(baud) )

comPort.openSerial(port, baud)


print("Calibrating accelerometer")
print("DO NOT MOVE")

data = [];
#Takes accelerometer data to perform calibrations
for i in range(0, 39):
    print(data)
    rawData = comPort.readSerial(port, byte)
    rawArray = calibrate.formatData(rawData)
    data.append(rawArray)

#Takes one component of acceleration to perform calculationss
data = numpy.array(data)
accel = data[:, txyz]


#Calibrates acceleromter
offset = calibrate.offsetAccel(accel, numpy)

accel = (accel[:] - offset)

if accel.all() == False:
    print("You moved it. Restart the process")
    exit()

print("Calibrated. \nBegin Compressions")

#Performs analysis on compressions every 2 seconds concurrent with compressions
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
    if (comPort.idle(accel, 10)):
        continue
    [sofT, rate] = spectralAnalysis.calculations(sTime, accel, numpy)

    feedback.depth(sofT, maxDepth, minDepth, depthTolerance)
    feedback.rate(rate, maxRate, minRate, rateTolerance)
    print("----------------------------------------------------------------------------")
