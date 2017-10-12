def formatData(data):
    data = data.split(', ')

    for i in range(len(data)):
        #data[i] = data[i].strip()
        data[i] = float(data[i])
    data[0] = int(data[0])

    return data


def offsetAccel(accel, xyz, numpy):
    offset = []
    tmp = max(accel) - min(accel)
    if tmp > 0.2:
        accel[:] = False
        return accel

    offset.append(numpy.mean(accel))

    return offset

def scaleTime(time):
    time = (time - time[0]) / 1000

    return time
