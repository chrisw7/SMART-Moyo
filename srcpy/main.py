from time import sleep
import calibrate
import numpy
import comPort
import msvcrt

#API Key pxkXiGLfWlArewVQM5Nv
#py = plotly.plotly("Username", "API-Key")

port = "COM5"
baud = 2400
bytes = 26  #208 bits
#seconds =2400/208 = 11.5
print("Using COM5 as default, and baudrate of 19200")

comPort.openSerial(port, baud)

print("Calibrating accelerometer")
print("DO NOT MOVE")

data = [];
for i in range(0, 39):
    rawData = comPort.readSerial(port, bytes)
    rawArray = calibrate.formatData(rawData)
    data.append(rawArray)

data = numpy.array(data)
time = data[:,0]
accel = data[:, 1:4]

[time, accel] = calibrate.offsetData(time, accel, numpy)
print(time)

if time.all() == False and accel.all() == False:
    print("You moved it. Restart the process")
    exit()


sleep(0.5)
print("Calibrated")

sleep(0.5)
print("Begin Compressions")


while True:
    rawData = comPort.readSerial(port)
    rawArray = rawData.split(',').strip()
    #Put code in here
