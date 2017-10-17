from matplotlib import style

def plot(x, y, xlbl, ylbl, title, subplt, num, plt):

    if num == 1:
        plt.close()
    style.use('dark_background')

    plt.subplot(subplt)
    plt.plot(x, y)
    plt.xlabel(xlbl)
    plt.ylabel(ylbl)
    plt.title(title)
    #plt.draw()

    return
