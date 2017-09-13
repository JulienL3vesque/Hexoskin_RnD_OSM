# -*- coding: utf-8 -*-
"""
Created on Tue Aug  1 11:42:52 2017

@author: Mostafa Hammoud

This function is responsible for showing a real time plot
It takes ONLY one ECG and plots it along with the points of interest
"""

# -*- coding: utf-8 -*-
"""
Created on Thu Jul 20 13:45:15 2017

@author: Mostafa Hammoud

This function is responsible for showing a real time plot
It takes the ECG we have and plots it along with the points of interest
"""

import numpy as np
import matplotlib.pyplot as plt
from various_functions import plot_points
def plot(long_filt_ecg, time, long_time, index, fs, canvas, ecg_type, figure):
    
    gap= 30
    start = int(time[0]*fs) - 1
    end   = int(time[-1]*fs)
    
    if start < 0:
        start = 0
        
    plot_range = np.arange(start,end,gap)
    
    if plot_range[-1] < end + 1:
        plot_range = np.append(plot_range,end)

    
    for i in plot_range:
        plt.figure(figure.number)
        plt.title(ecg_type)
        plt.xlabel('Time (S)')
        plt.ylabel('Voltage (mV)')
        axes = plt.gca()
        axes.set_ylim([-3,3])
        axes.set_color_cycle(['blue','red'])
        plt.plot(long_time[start:int(i)],long_filt_ecg[start:int(i)])
        plot_points(long_filt_ecg, index, long_time, start, int(i))
        if int(i/fs) - 2 >= 0:
            plt.xlim(int(i)/fs-2,int(i)/fs)
        else:
            plt.xlim(time[0],time[-1])
        
        canvas.draw()
        plt.pause(0.05)
    
    plt.figure(figure.number)
    plt.clf()
    plt.title(ecg_type)
    plt.xlabel('Time (S)')
    plt.ylabel('Voltage (mV)')
    plt.plot(long_time[start:end],long_filt_ecg[start:end])
    plot_points(long_filt_ecg, index, long_time, start, end)
    plt.xlim(int(plot_range[-1])/fs-2,int(plot_range[-1])/fs)
