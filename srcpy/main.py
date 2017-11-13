from time import time as cTime
import calibrate
import comPort
import feedback
import numpy
import os
import spectralAnalysis
import sys
import time
import _thread as thread

def close_program(L, sysVersion):
    inpt = ""
    if int(sysVersion) < 3:
        inpt = raw_input()
    else:
        inpt = input()
    L.append(inpt)

filePath = "records"
sysVersion = sys.version[0]

L = []
thread.start_new_thread(close_program, (L,sysVersion))

fileName = "junaid" #feedback.getUser(sysVersion)
#age = feedback.getAge(sysVersion)

if not os.path.exists(filePath):
    os.makedirs(filePath)

#Official recommended ranges for CPR rate (cpm) and depth (cm)
#Adjusts depending on age of person (adult, youth, child, infant)
minDepth, maxDepth, depthTolerance = calibrate.age(sys.argv[0])
minRate, maxRate, rateTolerance = 100, 120, 5

GRAVITY = 9.80665

compressionresetTime = 2
txyz = 3 #Z index

#Dynamically
port = comPort.findPorts()

#seconds = 2400 bps / 208 bits = 11.5 /second
baud = 115200
byte = 26  #208 bits
print("Using " + str(port) + " as default, and baudrate of " + str(baud) )

#Opens the serial port
comPort.openSerial(port, baud)

print("Calibrating accelerometer")
print("DO NOT MOVE")

data = [];
#Takes accelerometer data to perform calibrations
for i in range(0, 39):
    rawData = comPort.readSerial(port, byte)
    rawArray = calibrate.formatData(rawData, numpy)
    data.append(rawArray)

#Takes one component of acceleration to perform calculationss
data = numpy.array(data)
accel = data[:, txyz]


#Calibrates acceleromter
offset = calibrate.offsetAccel(accel, numpy)

accel = (accel[:] - offset)

if accel.all() == False:
    print("You moved it. Restart the process")
    time.sleep(1)
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
        rawArray = calibrate.formatData(rawData, numpy)

        data.append(rawArray)
        data = numpy.array(data)

        sTime = data[:, 0]
        accel = data[:, txyz]
        data = data.tolist()

        sTime = calibrate.scaleTime(sTime)
        accel = (accel[:] - offset)*GRAVITY

        if L:
            print("You have closed the program")
            time.sleep(0.5)
            exit()

    #Call fft here
    if (comPort.idle(accel, 10)):
        continue
    [sofT, rate] = spectralAnalysis.calculations(sTime, accel, numpy)

    [depth, rate] = feedback.depth_rate(sofT, maxDepth, minDepth, depthTolerance, rate, maxRate, minRate, rateTolerance)


    feedback.writeToFile(filePath, fileName, depth, rate)


    print("----------------------------------------------------------------------------")
