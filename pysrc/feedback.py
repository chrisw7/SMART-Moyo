import csv

def getUser(sysVersion):
    msg = "Please Enter in Your Name: "
    if int(sysVersion) < 3:
        userName = raw_input(msg)
    else:
        userName = input(msg)


    return userName

def getAge(sysVersion):
    msg = "Please Specify if adult/youth/child/infant: "
    if int(sysVersion) < 3:
        age = raw_input(msg)
    else:
        age = input(msg)
    return age.lower()

#Some arbitrary algorithm
def getExistingScore(filePath, absRate, absDepth, numpy, sysVersion):
    rates = []
    depths = []
    if int(sysVersion) < 3:
        with open(filePath, 'rb') as csvfile:
            return getScores(csvfile, rates, depths, absRate, absDepth, numpy)

    else:
        with open(filePath, 'r') as csvfile:
            return getScores(csvfile, rates, depths, absRate, absDepth, numpy)


def getScores(csvfile, rates, depths, absRate, absDepth, numpy):
    f = csv.reader(csvfile, quotechar='|', quoting=csv.QUOTE_MINIMAL)
    for row in f:
        if row:
            rates.append(int(row[0]))
            depths.append(float(row[1]))

            #Include standard deviation in this?
    avgRate = numpy.mean(rates)
    avgDepth = numpy.mean(depths)

    rateScore = abs(avgRate - absRate)/absRate + numpy.std(rates)
    depthScore = abs(avgDepth - absDepth)/absDepth + numpy.std(depths)

    return rateScore, depthScore



def getNewScore(filePath, absRate, absDepth, iteration, numpy, sysVersion):
    currentScore = getExistingScore(filePath, absRate, absDepth, numpy, sysVersion)

    return currentScore

def writeToRecord(filePath, depth, rate, sysVersion):
    if int(sysVersion) < 3:
        with open(filePath, 'a+b') as csvfile:
            f = csv.writer(csvfile, quotechar='|', quoting=csv.QUOTE_MINIMAL)
            f.writerow([int(rate), depth])
    else:
        with open(filePath, 'a+') as csvfile:
            f = csv.writer(csvfile, quotechar='|', quoting=csv.QUOTE_MINIMAL)
            f.writerow([int(rate), depth])

    return

def compareScore(currentScore, previousScore):
    msgDepth = ""
    msgRate = ""
    if not currentScore or not previousScore:
        return "", ""

    if currentScore[0] < previousScore[0]:
        msgDepth = "Better Depth Than Your Previous Attempt"
    elif currentScore[0] > previousScore[0]:
        msgDepth = "Worse Depth Than Your Previous Attempt"
    else:
        msgDepth = "About the Same as Your Previous Attempt"

    if currentScore[1] < previousScore[1]:
        msgRate = "Better Rate Than Your Previous Attempt"
    elif currentScore[1] > previousScore[1]:
        msgRate = "Worse Rate Than Your Previous Attempt"
    else:
        msgRate = "About the Same Than Your Previous Attempt"

    return msgDepth, msgRate

#Returns depth feedback to user based on standards and compression quality
def depth_rate(sofT, maxDepth, minDepth, depthTol, rate, maxRate, minRate, rateTol, msgDepth, msgRate):

    if type(sofT) == int:
        print("Did you stop doing compressions?")
        return

    depth = max(sofT) - min(sofT)

    if len(str(depth)) >= 5:
        tmp = ""
        for i in range(4):
            tmp += str(depth)[i]
        depth = float(tmp)

    print("Depth: " + str(depth) + " cm")
    depthFeedback = "Depth: " + str(depth) + "\n"
    if  depth > maxDepth + depthTol:
        depthFeedback += "Too Deep"
        print("Too Deep" + "\t" + msgDepth)
    elif depth < minDepth - depthTol:
        depthFeedback += "Too Shallow"
        print("Too Shallow" + "\t" + msgDepth)
    else:
        depthFeedback += "Good Depth"
        print("Good Depth" + "\t" + msgDepth)

    print("")

    print("Rate: " + str(rate) + " cpm")
    rateFeedback = "Rate: " + str(rate) + "\n"
    if  rate > maxRate + rateTol:
        rateFeedback += "Too Fast"
        print("Too fast" + "\t" + msgRate)
    elif rate < minRate - rateTol:
        rateFeedback += "Too Slow"
        print("Too Slow" + "\t" + msgRate)
    else:
        rateFeedback += "Good Rate"
        print("Good Rate" + "\t" + msgRate)
        print("")

    return depth, rate
