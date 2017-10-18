#Returns depth feedback to user based on standards and compression quality
def depth(sofT, maxDepth, minDepth, tolerance):
    depth = max(sofT) - min(sofT)

    if  depth > maxDepth + tolerance:
        print("Too Deep")
    elif depth < minDepth - tolerance:
        print("Too Shallow")
    else:
        print("Good Depth")


    return


#Returns rate feedback to user based on standards and compression quality
def rate(rate, maxRate, minRate, tolerance):
    print(rate)
    if  rate > maxRate + tolerance:
        print("Too fast")
    elif rate < minRate - tolerance:
        print("Too Slow")
    else:
        print("Good Rate")

    return
