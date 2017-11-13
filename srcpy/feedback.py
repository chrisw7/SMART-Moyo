import csv

def getUser(sysVersion):
    msg = "Please Enter in Your Name: "
    if int(sysVersion) < 3:
        print("You are running Python2\n")
        userName = raw_input(msg)
    else:
        print("You are running Python3\n")
        userName = input(msg)

    return userName

def getAge(sysVersion):
    msg = "Please Specify if adult/youth/child/infant: "
    if int(sysVersion) < 3:
        age = raw_input(msg)
    else:
        age = input(msg)
    return age.lower()

def writeToFile(filePath, fileName, depth, rate):
    with open(filePath + "/" + fileName + ".csv", 'a+b') as csvfile:
        f = csv.writer(csvfile, quotechar='|', quoting=csv.QUOTE_MINIMAL)
        f.writerow([int(rate), depth])
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
