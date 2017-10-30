#Returns depth feedback to user based on standards and compression quality
#Returns rate feedback to user based on standards and compression quality
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

    f = open("feedback.txt", "a+")
    f.write("\n" + depthFeedback + "\n" + rateFeedback + "\n")

    return
