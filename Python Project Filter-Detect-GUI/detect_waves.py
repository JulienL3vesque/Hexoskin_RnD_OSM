"""
Created on thu Jun  1 08:20:07 2017

@author: Mostafa Hammoud

This function detects the PQST waves
"""
import numpy as np
import various_functions
import operator
from scipy.signal import find_peaks_cwt

def detect_waves(long_ecg, index, peaks, found, fs):

    rr = np.diff(peaks)
    # Remove any rate that is not in this range not in a +- 30 range
    # Since sometimes we might have bad peaks that were detected
    rr = various_functions.remove_unwanted(rr, (np.mean(rr) + 30     ) 
                                           ,(np.mean(rr) - 30), False)
    
    # Set the window for the search
    if np.size(rr) > 0:
        
        rr = np.mean(rr)
        
        q_window       = int(np.round(rr*0.12))
        qon_window     = int(np.round(rr*0.03))
        p_window_start = int(np.round(rr*0.25))
        p_window_end   = int(np.round(rr*0.1 ))
        pon_window     = int(np.round(rr*0.08))
        poff_window    = int(np.round(rr*0.08))
        s_window       = int(np.round(rr*0.12))
        soff_window    = int(np.round(rr*0.04))
        t_window_start = int(np.round(rr*0.18 ))
        t_window_end   = int(np.round(rr*0.5 ))
        ton_window     = int(np.round(rr*0.14))
        toff_window    = int(np.round(rr*0.14))
    else:
        q_window       = int(np.round(60 *fs/1000))
        qon_window     = int(np.round(20 *fs/1000))
        p_window_start = int(np.round(200*fs/1000))
        p_window_end   = int(np.round(40 *fs/1000))
        pon_window     = int(np.round(60 *fs/1000))
        poff_window    = int(np.round(60 *fs/1000))
        s_window       = int(np.round(80 *fs/1000))
        soff_window    = int(np.round(25 *fs/1000))
        t_window_start = int(np.round(150*fs/1000))
        t_window_end   = int(np.round(350*fs/1000))
        ton_window     = int(np.round(100*fs/1000))
        toff_window    = int(np.round(100*fs/1000))
    
    # Loop throught the R waves and determine the adjacent waves
    for i in range(len(peaks)):
        
        start = peaks[i] - q_window
        end   = peaks[i]
        q_index, qon_index = detect_troughs(long_ecg, start, end, fs,
                                            qon_window = qon_window)
        
        start = peaks[i]
        end   = peaks[i] + s_window
        s_index, soff_index = detect_troughs(long_ecg, start, end, fs,
                                            soff_window = soff_window)
        
        start = peaks[i] - p_window_start
        end   = peaks[i] - p_window_end
        p_index, pon_index, poff_index = detect_peaks(long_ecg, start, end, fs,
                                                      pon_window, poff_window)
        
        start = peaks[i] + t_window_start
        end   = peaks[i] + t_window_end
        t_index, ton_index, toff_index = detect_peaks(long_ecg, start, end, fs,
                                                      ton_window, toff_window)        
        
        index.add_p   (p_index, pon_index, poff_index)
        index.add_q   (q_index, qon_index)
        index.add_s   (s_index, soff_index)
        index.add_t   (t_index, ton_index, toff_index)
        
        if p_index:
            found.add_p(1)
        else:
            found.add_p(0)
        
        if q_index:
            found.add_q(1)
        else:
            found.add_q(0)
            
        if s_index:
            found.add_s(1)
        else:
            found.add_s(0)
            
        if t_index:
            found.add_t(1)
        else:
            found.add_t(0)
        
        
    return index, found
        

        
"""
 This function detects the troughs and their start or end
    
    \          /
     \        /
      \      /
       \    /
        \  /
         \/
       trough
"""        
      
def detect_troughs(long_ecg, start, end, fs,qon_window = [], soff_window = []): 
   
    # If we don't have enough data then we can't search
    if ((start < 0) or (end > len(long_ecg))):
        return [],[]
    
    # Find the troughs
    trough = find_peaks_cwt(-long_ecg[start:end], np.arange(1,50))
    
    # If no trough was detected then we don't have one
    if len(trough) > 0:
        trough_index = [x + start for x in trough]
    else:
        return [],[]
    
    # Get the mean of the troughs
    mean = np.abs(np.mean(long_ecg[trough_index]))    
    
    # Loop through the troughs and get the closest significant trough
    for i in range(len(trough)-1, -1, -1):
        if np.abs(long_ecg[trough_index[i]]) > 0.7*mean:
            index = trough_index[i] - 1
            break
    
    # If we are working with Q wave then we need to find where is begins
    if np.size(qon_window) > 0:
        
        # If we don't have enough data before the peak then we cant search
        if (start - qon_window) < 0 :
            return [],[]
        
        # Calculate the derivative
        dy = various_functions.derivative(long_ecg[index-qon_window:index], fs)
        # Find the mean of the derivative
        mean = np.abs(np.mean(dy))
        
        # Loop through the derivative and check when mean the derivative is
        # less than the mean, this indicates the begining of the trough
        
        # Set Qon incase the loop ends without finding a change in slope
        qon_index = index - qon_window
        
        for i in range(qon_window-1, 0, -1):
            if np.abs(dy[i]) < mean:
                qon_index = index - qon_window + i
                break
        
        return index, qon_index
    
    # If we are working with S wave then we need to find where is end
    if np.size(soff_window) > 0:
        
        # If we don't have enough data we can't search
        if (index + soff_window) >= len(long_ecg):
            return [],[]
        
        # Calculate the derivative
        dy = various_functions.derivative(long_ecg[index + 1:index+soff_window],fs)
        
        mean = np.abs(np.mean(dy))
        
        # Loop through the derivative and check when mean the derivative is
        # less than the mean, this indicates the end of the trough
        
        # Set Qon incase the loop ends without finding a change in slope
        soff_index = index + soff_window
    
        for i in range(soff_window-3):
            if np.abs(dy[i + 1]) - np.abs(dy[i]) < 0:
                soff_index = index + i + 1
                break
        
        return index, soff_index
    
    # Added just for safety
    return index


"""
This function detects the peaks and where they start and end
"""
def detect_peaks(long_ecg, start, end, fs, on_window, off_window): 
    
    # If we don't have enough data we can't search
    if start < 0:
        return [],[],[]
    
    # Find the peaks
    peak = find_peaks_cwt(long_ecg[start:end], np.arange(1,100))
    
    # If no peak was detected then we dont have one
    if len(peak) > 0:
        index = [x + start for x in peak]

    else:
        return [],[],[]
    
    
    max_index, max_value = max(enumerate(long_ecg[index]), 
                               key=operator.itemgetter(1))
    
    # Select the highest peak
    index = index[max_index] - 1
    
    if (index + off_window) >= len(long_ecg) or (index - on_window) < 0:
        return [],[],[]
    
    # Calculate the derivative
    dy = various_functions.derivative(long_ecg[index - on_window:index], fs)
    
    mean = np.abs(np.mean(dy))
        
    # Loop through the derivative and check when mean the derivative is
    # less than the mean, this indicates the  beginning of the peak
        
    # Set on_index incase the loop ends without finding a change in slope
    on_index = index - on_window
        
    for i in range(on_window-8, 0, -1):
        if np.abs(dy[i]) < mean:
            on_index = index - on_window + i
            break
    
    # Calculate the derivative
    dy = various_functions.derivative(long_ecg[index : index+off_window],fs)
        
    mean = np.abs(np.mean(dy))
        
    # Loop through the derivative and check when mean the derivative is
    # less than the mean, this indicates the end of the peak
        
    # Set off index incase the loop ends without finding a change in slope
    off_index = index + off_window
    
    for i in range(off_window-5):
        if np.abs(dy[i+5]) < mean:
            off_index = index + i + 5
            break
    
    return index, on_index, off_index
    
    
    
    