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
def getExistingScore(filePath, absRate, absDepth, numpy):
    rateScore = []
    depthScore = []

    with open(filePath, 'rb') as csvfile:
        f = csv.reader(csvfile, quotechar='|', quoting=csv.QUOTE_MINIMAL)
        for row in f:
            rateScore.append(int(row[0]))
            depthScore.append(float(row[1]))

        #Include standard deviation in this
        avgRate = numpy.mean(rateScore)
        avgDepth = numpy.mean(depthScore)

        rateScore = 1 - abs(avgRate - absRate)/absRate
        depthScore =  1 - abs(avgDepth - absDepth)/absDepth

    return rateScore, depthScore

def getNewScore(filePath, absRate, absDepth, iteration, numpy):
    if iteration < 5:
        return
    currentScore = getExistingScore(filePath, absRate, absDepth, numpy)

    return currentScore

def writeToRecord(filePath, depth, rate):
    with open(filePath, 'a+b') as csvfile:
        f = csv.writer(csvfile, quotechar='|', quoting=csv.QUOTE_MINIMAL)
        f.writerow([int(rate), depth])
    return

def compareScore(currentScore, previousScore):
    print(currentScore)
    print(previousScore)

    if previousScore[0] <= 1 and previousScore[1] <= 1:
        if currentScore[0] > previousScores[0]:
            print("Better Depth")
        elif currentScore[0] < previousScores[0]:
            print("Worse Depth")
        else:
            print("About the Same")

        if currentSscore[1] > previousScore[1]:
            print("Better Rate")
        elif currentSscore[1] < previousScore[1]:
            print("Worse Rate")
        else:
            print("About the Same")
    else:
         print("Your Previous Score is Incosistent, and cannot be compared properly")
    return

#Returns depth feedback to user based on standards and compression quality
def depth_rate(sofT, maxDepth, minDepth, depthTol, rate, maxRate, minRate, rateTol):
    if type(sofT) == int:
        print("Did you stop doing compressions?")
        return

    depth = max(sofT) - min(sofT)
    print("Depth: ", str(depth))
    depthFeedback = "Depth: " + str(depth) + "\n"

    if  depth > maxDepth + depthTol:
        depthFeedback += "Too Deep"
        print("Too Deep")
    elif depth < minDepth - depthTol:
        depthFeedback += "Too Shallow"
        print("Too Shallow")
    else:
        depthFeedback += "Good Depth"
        print("Good Depth")

    print("")

    print("Rate: ", str(rate))
    rateFeedback = "Rate: " + str(rate) + "\n"
    if  rate > maxRate + rateTol:
        rateFeedback += "Too Fast"
        print("Too fast")
    elif rate < minRate - rateTol:
        rateFeedback += "Too Slow"
        print("Too Slow")
    else:
        rateFeedback += "Good Rate"
        print("Good Rate")
        print("")

    return depth, rate


    return
