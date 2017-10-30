#Splits time and xyz accleration into an array [t,x,y,z]
def formatData(data, numpy):
    if "\r\n" in data:
        data = data.replace("\r\n","")

    data = data.split(',')
    frmtData  = numpy.zeros(4)
    for i in range(0, 4):
        frmtData[i] = data[i].strip()
        frmtData[i] = float(data[i].encode('utf-8'))
    #data[0] = int(data[0])

    return frmtData

#Returns average of stationary acceleromater
def offsetAccel(accel, numpy):
    tmp = max(accel) - min(accel)
    if tmp > 0.2:
        accel[:] = False
        return accel

    return numpy.mean(accel)

#Converts time from ms to s
def scaleTime(time):
    time = (time - time[0]) / 1000

    return time

#Returns mindepth, maxdepth and tolerance based
def age(arg):
    if arg == "infant".lower():
        return 2, 3, 0.5
    elif arg == "child".lower():
        return 3, 4, 0.5
    elif arg == "youth".lower():
        return 4, 5, 1
    elif arg == "adult".lower():
        return 5, 6, 1
    else:
        return 5, 6, 1
