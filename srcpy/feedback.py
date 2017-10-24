#Returns depth feedback to user based on standards and compression quality
def depth(sofT, maxDepth, minDepth, tolerance):
    depth = max(sofT) - min(sofT)
    print("Depth: ", str(depth))

    if  depth > maxDepth + tolerance:
        print("Too Deep")
    elif depth < minDepth - tolerance:
        print("Too Shallow")
    else:
        print("Good Depth")

    print("")
    return


#Returns rate feedback to user based on standards and compression quality
def rate(rate, maxRate, minRate, tolerance):
    print("Rate: ", str(rate))
    if  rate > maxRate + tolerance:
        print("Too fast")
    elif rate < minRate - tolerance:
        print("Too Slow")
    else:
        print("Good Rate")
    print("")
    return
