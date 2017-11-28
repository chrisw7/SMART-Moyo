from peakutils import peak
from math import atan2
from math import pi
import matplotlib.pyplot as plt
import graph

def calculations(time, accel, numpy):
    #Sampling Frequency
    Fs = 1/(time[1]-time[0])

    #Zero Padding
    N = len(time)

    #Apply hanning window over interval
    w = numpy.hanning(len(accel))
    coherentGain = sum(w)/len(accel)
    hanningApplied = numpy.zeros((len(accel)))
    hanningApplied = accel[:]*w[:]/coherentGain

    #Extract Windowed Double Sided FFT for phase and frequency analysis
    fftPolarDouble = numpy.fft.fft(hanningApplied, N)/N
    fftPolarSingle = fftPolarDouble[1:int(N/2) + 1]

    fftSmooth = abs(fftPolarSingle)
    end = len(fftPolarSingle)

    fftPolarSingle[2:end - 1] = 2*fftPolarSingle[2:end -1]
    fftSmooth[2:end - 1] = 2*fftSmooth[2:end -1]

    #Scale Frequency Bins
    freqBin = Fs*numpy.arange(int(N/2))/N
    ampl = []

    #Find first 3 largest peaks
    indexes = peak.indexes(fftSmooth, min_dist= 2 )
    for i in range(len(indexes)):
        ampl.append(fftSmooth[indexes[i]])
        Fs = indexes

    #Nuber of harmonics to extract from fft
    harmonics = len(ampl)
    if harmonics > 3:
        harmonics = 3

    #Calculating phase shift of acceleration and using fundamental frequency
    if len(indexes) > 1:
        z = fftPolarSingle[Fs[0:harmonics]]
        fcc = freqBin[Fs[0]]
        theta = numpy.arctan2(z[:].imag, z[:].real)
    elif len(indexes) == 1:
        z  = fftPolarSingle[numpy.int_(Fs)]
        fcc = freqBin[numpy.int_(Fs)]
        theta = numpy.arctan2(z.imag, z.real)
    else:
        return 0, 0

    #Calculating S_k (cm) given A_k(m/s/s) and fcc, finding phase shift
    A_k = ampl[0:harmonics]
    tmp = numpy.arange(1, harmonics + 1)
    tmp1 = (tmp*tmp)*(2*pi*fcc)**2
    S_k = 100*(A_k/tmp1)
    phi = theta + pi

    #Calculating Displacement Series
    sofT = numpy.zeros(len(time))
    if harmonics != 1:
        for i in range(0, harmonics):
            sofT += S_k[i]*numpy.cos(2*pi*(i+1)*fcc*time + phi[i])

    else:
        sofT = S_k*numpy.cos(2*pi*fcc*time + phi)

    depth = max(sofT) - min(sofT)
    try:
        rate = fcc[0]*60
    except:
        rate = fcc*60

    #Writes to txt (debugging only)

    #Plots graph (development only)
    #graph.plot(freqBin, fftSmooth, "fbin (s)", "Amplitude", "Distance vs Time", 311, 1, plt)
    #graph.plot(time, hanningApplied, "Time (s)", "Accel", "Hanning vs Time", 312, 0, plt)
    #graph.plot(time, sofT, "Time (s)", "Displacement", "Distance vs Time", 313, 0, plt)
    plt.show(block=False)

    return sofT, rate
