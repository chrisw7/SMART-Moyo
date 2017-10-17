def formatData(data):
    data = data.split(', ')

    for i in range(len(data)):
        #data[i] = data[i].strip()
        data[i] = float(data[i])
    data[0] = int(data[0])

    return data


def offsetAccel(accel, numpy):
    tmp = max(accel) - min(accel)
    if tmp > 0.2:
        accel[:] = False
        return accel

    return numpy.mean(accel)

def scaleTime(time):
    time = (time - time[0]) / 1000

    return time

#Returns mindepth, maxdepth and tolerance
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
