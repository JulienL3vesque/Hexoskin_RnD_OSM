

from filter    import filter
from read_ecg  import read_ecg
from ecg import qrs_detector
from scipy.signal import find_peaks_cwt


import matplotlib.pyplot as plt
import time as t
import numpy as np
import operator

file_name = 'Me_II.csv'
fs = 256

section  = 0
new_end  = []
long_ecg = np.empty(0)
long_filt_ecg = np.empty(0)
long_time = np.empty(0)
peaks    = []

time, ecg = read_ecg(file_name, 10*fs,12*fs+2, fs)
    
peaks = qrs_detector(fs,ecg)
    
filt_ecg = filter(ecg,fs)
        
plt.figure(1)
plt.title('Raw')
plt.plot(time,ecg)
plt.figure(2)
plt.title('Filtered')
plt.plot(time,filt_ecg)
plt.scatter(time[peaks],filt_ecg[peaks])

