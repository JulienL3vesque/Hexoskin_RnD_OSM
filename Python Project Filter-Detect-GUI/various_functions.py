# -*- coding: utf-8 -*-
"""
Created on Tue May 30 13:06:52 2017

@author: Mostafa Hammoud
This script contains various functions that will be used
"""

import numpy as np
import operator
from os import listdir
from os.path import isfile, join
from matplotlib import pyplot as plt
"""
This function takes the R waves that were detected and makes sure they are good 
R waves
"""
def fix_r(peaks,long_filt_ecg):
    # Loop through the peaks 
    for i in range (0,len(peaks)):
        # Select a range close to the peaks to check the maximum
        temp_range = np.arange(peaks[i] - 10,peaks[i] + 10)
        
        # If we have a negative R wave we don't want to confuze it with a 
        # significant S wave
        if long_filt_ecg[peaks[i]] < 0:
            temp_range = np.arange(peaks[i] - 15,peaks[i] + 10)
        # Make sure the range does not go out of bound
        if temp_range[-1] >= len(long_filt_ecg):
            temp_range = np.arange(peaks[i] - 6,len(long_filt_ecg) - 1)
        # Find the maximum
        max_index, max_value = max(enumerate(long_filt_ecg[temp_range]), 
                                   key=operator.itemgetter(1))
        # Set the peak to the maximum that was found
        peaks[i] = max_index + temp_range[0]
        
    return peaks
    
"""
This function takes an uper limit and a lower limit and removes all values that
are not in that range
upper: Upper limit
lower: Lower limit
equal: Boolean to select if the limits are included. Default is True

"""    
def remove_unwanted(array, upper, lower, equal = True):
    
    out = []
    
    for i in array:
        # i can be []
        if np.size(i) > 0:
            if equal is True:
                if (i >= lower and i <= upper):
                    out.append(i)
            else:
                if (i > lower and i < upper):
                    out.append(i)            
    
    # Select the peaks that are inside the range start to end
    array = out
    
    return array
"""
This function returns the an array with the path to all three ECGs
"""
def get_ecg_path(file_name):
    
    ecg_path = [f for f in listdir(file_name) if isfile(join(file_name,f))]
    
    j = 0
    for i in ecg_path:
        
        if 'ECG_I.csv' in i or 'ECG_II.csv' in i or 'ECG_III.csv' in i:
            ecg_path[j] = file_name + '\\' + i
            j += 1
        
    return ecg_path
"""
This function calculates the derivative
"""
def derivative(y, fs):
    
    if len(y) < 2:
        return 0
        
    dy = np.zeros(len(y),np.float)
    dx = 1/fs
    
    dy[0:-1] =  np.diff(y)/dx
      
    dy[-1] = (y[-1] - y[-2])/dx
    
    return dy

"""
This function plots the points on the figure
"""
def plot_points(long_ecg, index, long_time, start, end):
    
    r = remove_unwanted(index.r, end, start)  
    
    if (len(r)):
        
        p = remove_unwanted(index.p, end, start)  
        
        q = remove_unwanted(index.q, end, start)  

        s = remove_unwanted(index.s, end, start)  

        t = remove_unwanted(index.t, end, start)  
        
        pon  = remove_unwanted(index.pon , end, start) 
        poff = remove_unwanted(index.poff, end, start)  
        qon  = remove_unwanted(index.qon , end, start)  
        soff = remove_unwanted(index.soff, end, start)  
        ton  = remove_unwanted(index.ton , end, start)  
        toff = remove_unwanted(index.toff, end, start)  
        
        plt.scatter(long_time[r],long_ecg[r], color = 'red')
        plt.scatter(long_time[p],long_ecg[p], color = 'blue')
        plt.scatter(long_time[q],long_ecg[q], color = 'green')
        plt.scatter(long_time[s],long_ecg[s], color = 'magenta')
        plt.scatter(long_time[t],long_ecg[t], color = 'black')
        
        #plt.scatter(long_time[pon],long_ecg[pon])
        #plt.scatter(long_time[poff],long_ecg[poff])
        #plt.scatter(long_time[qon],long_ecg[qon])
        #plt.scatter(long_time[soff],long_ecg[soff])
        #plt.scatter(long_time[ton],long_ecg[ton])
        #plt.scatter(long_time[toff],long_ecg[toff])

"""

This function loops thorugh the index from start to end and fixes the location 
of the peaks or troughs. Since sometimes we might have a small shift in their 
location

If the start and end were not indicated then we loop through the whole index

If 

"""
def fix_peaks(long_ecg, wave_index, start_index, end_index, peak = False, 
              trough = False):
    # If we are dealing with a peak, then we keep the ecg as it is
    if peak:
        ecg = long_ecg.copy()
    # If we are dealng with a trough, then we inverse the ecg so the min is max
    elif trough:
        ecg = -long_ecg.copy()  
    else:
        print('A type must be selected')
        return

    for i in range(start_index, end_index):
        if np.size(wave_index[i]) > 0:
            temp_range = np.arange(wave_index[i] - 2,wave_index[i] + 3)
        
            if temp_range[-1] >= len(ecg):
                temp_range = np.arange(wave_index[i] - 2,len(ecg) - 1)
        
            # Find the maximum
            max_index, max_value = max(enumerate(ecg[temp_range]), 
                                       key=operator.itemgetter(1))
        
            # Set the peak to the maximum that was found
            wave_index[i] = max_index + temp_range[0]

    return wave_index