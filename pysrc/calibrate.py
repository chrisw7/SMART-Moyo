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
    if arg.lower() == "infant":
        return 2, 3, 0.5
    elif arg.lower() == "child":
        return 3, 4, 0.5
    elif arg.lower() == "youth":
        return 4, 5, 1
    elif arg.lower() == "adult":
        return 5, 6, 1
    else:
        return 5, 6, 1
