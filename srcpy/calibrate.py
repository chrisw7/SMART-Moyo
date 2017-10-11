def formatData(data):
    data = data.split(', ')

    for i in range(len(data)):
        #data[i] = data[i].strip()
        data[i] = float(data[i])
    data[0] = int(data[0])

    return data


def offsetData(time, accel, numpy):
    offset = []
    for i in range(0,3):
        tmp = max(accel[:, i]) - min(accel[:, i])
        if tmp > 0.2:
            time[:] = False
            accel [:,:] = False
            return time, accel

        offset.append(numpy.mean(accel[:, i]))

    #for i in range(len(time)):
    time = abs(time[:] - time[0])
    accel = abs(accel[:] - offset)

    return time, accel
