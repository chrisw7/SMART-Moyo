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

repeatUser = False
directory = "records"
sysVersion = sys.version[0]

fileName = feedback.getUser(sysVersion)
age = feedback.getAge(sysVersion)

GRAVITY = 9.80665
compressionresetTime = 2
txyz = 3 #Z index

filePath = directory + "/" + fileName + "_" + age + ".csv"

#Official recommended ranges for CPR rate (cpm) and depth (cm)
#Adjusts depending on age of person (adult, youth, child, infant)
minDepth, maxDepth, depthTolerance = calibrate.age(age)
minRate, maxRate, rateTolerance = 100, 120, 5

print("You have input: " + str(age) + "\n")
print("Your constraints are: \n")
print("Min Depth: " + str(minDepth) + "\n")
print("Max Depth: " + str(maxDepth) + "\n")
print("Depth Tolerance: " + str(depthTolerance) + "\n")

time.sleep(0.4)

if not os.path.exists(directory):
    os.makedirs(directory)

if os.path.isfile(filePath):
    repeatUser = True
    previousScore = feedback.getExistingScore(filePath,
                numpy.mean([minRate, maxRate]),
                numpy.mean([minDepth, maxDepth]),
                numpy,
                sysVersion)
    os.remove(filePath)


#Dynamically find ports on Linux or Windows
#Sets seconds = 2400 bps / 208 bits = 11.5 /second
port = comPort.findPorts()
baud = 115200
byte = 26  #208 bits

#Opens the serial port
comPort.openSerial(port, baud)

print("\nCalibrating accelerometer")
print("\nDO NOT MOVE\n\n\n")

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

print("Calibrated \n\nBegin Compressions")

L = []
thread.start_new_thread(close_program, (L,sysVersion))

#Performs analysis on compressions every 2 seconds concurrent with compressions
iteration = 0
minIterations = 5
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

    if repeatUser:
        iteration += 1
        if iteration > minIterations:
            currentScore = feedback.getNewScore(filePath,
            numpy.mean([maxRate, minRate]),
            numpy.mean([maxDepth, minDepth]),
            iteration,
            numpy,
            sysVersion)

            msgDepth, msgRate = feedback.compareScore(currentScore, previousScore)

    if iteration > minIterations:
        [depth, rate] = feedback.depth_rate(sofT,
                        maxDepth,
                        minDepth,
                        depthTolerance,
                        rate,
                        maxRate,
                        minRate,
                        rateTolerance,
                        msgDepth,
                        msgRate)
    else:
        [depth, rate] = feedback.depth_rate(sofT,
                        maxDepth,
                        minDepth,
                        depthTolerance,
                        rate,
                        maxRate,
                        minRate,
                        rateTolerance,
                        "", "")

    feedback.writeToRecord(filePath, depth, rate, sysVersion)

    print("\nUser:  " + fileName)
    print("\n----------------------------------------------------------------------------\n\n\n\n\n\n")
