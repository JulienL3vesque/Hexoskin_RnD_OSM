"""
Created on Fri May 25 12:42:00 2017

@author: Mostafa Hammoud

This function filters the ECG by applying a two notch filters then a high pass 
followed by a low pass
The purpose of the notch filters is to make sure certain frequencies are 
removed.
"""

import numpy as np    

from scipy         import signal
from scipy.signal  import lfilter
from filter_design import iirnotch
    
def filter(ecg, fs):
    
    # The frequency of the notch     filter is 60 Hz
    # The frequency of the High Pass filter is 0.5 Hz
    # The frequency of the Low Pass  filter is 25 Hz
    notch_freq = 60
    high_freq  = 25
    low_freq   = 1
    n = 5
    
    filt_ecg = ecg
    # Notch filter at 60 Hz
    b, a = iirnotch(notch_freq/(fs/2), 30)
    filt_ecg = lfilter(b, a, filt_ecg)
    
    # Notch filter at 0.5 Hz
    b, a = iirnotch(low_freq/(fs/2), 30)
    filt_ecg = lfilter(b, a, filt_ecg)

    # High Pass at 0.5 Hz
    b, a = signal.butter(n,low_freq/(fs/2),'high')
    filt_ecg = signal.filtfilt(b, a, filt_ecg, padlen = 150)
    
    # Low Pass at 25 Hz
    b, a = signal.butter(n,high_freq/(fs/2),'low')
    filt_ecg = signal.filtfilt(b, a, filt_ecg, padlen = 150)

    #temp = np.floor(max(filt_ecg)/10)
    
    #while temp > 0:
    while max(filt_ecg)>5:
        filt_ecg = filt_ecg/10
        #temp = np.floor(max(filt_ecg)/10)

   
    return filt_ecg
"""
This function smoothes the curve but applies a noticable change to the 
amplitude. So it is best if it is only used to only get the location of the
wave 
"""
def smooth_curve(ecg, window_length = 37, filter_order = 4):
    smooth_signal = signal.savgol_filter(ecg, window_length, filter_order)
    return smooth_signal