# -*- coding: utf-8 -*-
"""
Created on Thu May 26 08:27:43 2017

@author: Mostafa Hammoud

This is the main script
"""

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
k = 1
while(1):

    section = section + 1
    
    start = 2*(section - 1)*(fs + 1)         
              
    if new_end:
        start = new_end + 1
        
    end   = start + 2*fs - 1 + 2
    
    
    # Read 3 seconds of data to detect the peaks but only the first 2 seconds 
    # will be used
    time, ecg = read_ecg(file_name, start, end + fs, fs)
    
    peaks = qrs_detector(fs,ecg,filter_length = (end-start + fs))
    
    peaks = np.array(peaks + start)
    
    ecg  = ecg[:-fs-1 + 2]
    time = time[:-fs-1 + 2]
    
    wanted_peaks = np.zeros(len(peaks),dtype=bool)
    j = 0
    for i in peaks:
        if (i >= start and i <= end):
            wanted_peaks[j] = True
        j+=1

    
    peaks = peaks[wanted_peaks]
    
    long_ecg = np.append(long_ecg,ecg)
    long_time = np.append(long_time,time)
    #if peaks[-1] > 
    
    if len(long_ecg) > 10*fs:
        filt_ecg = filter(long_ecg[-10*fs - 2:],fs) 
        filt_ecg = filt_ecg[-2*fs - 2:]
    else:
        filt_ecg = filter(long_ecg,fs)
        filt_ecg = filt_ecg[-2*fs - 2:]
    
    long_filt_ecg = np.append(long_filt_ecg,filt_ecg)
    
    for i in range (0,len(peaks)):
        temp_range = np.arange(peaks[i] - 6,peaks[i] + 7)
        if temp_range[-1] >= len(long_filt_ecg):
            temp_range = np.arange(peaks[i] - 6,len(long_filt_ecg) - 1)
            
        max_index, max_value = max(enumerate(long_filt_ecg[temp_range]), 
                                   key=operator.itemgetter(1))
        peaks[i] = max_index + temp_range[0]
        
    
        
    if len(long_filt_ecg)%5140 is 0:
        k += 2
        
    plt.figure(k)
    plt.title('Raw')
    plt.plot(time,ecg)
    plt.figure(k+1)
    plt.title('Filtered')
    plt.plot(time,filt_ecg)
    if (len(peaks)):
        plt.scatter(long_time[peaks],long_filt_ecg[peaks])

   # t.sleep(1)
    