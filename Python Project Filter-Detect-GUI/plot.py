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
def plot(long_filt_ecg, time, long_time, index, fs):
    
    gap= 30
    start = int(time[0]*fs) - 1
    end   = int(time[-1]*fs)
    
    if start < 0:
        start = 0
        
    plot_range = np.arange(start,end,gap)
    
    if plot_range[-1] < end + 1:
        plot_range = np.append(plot_range,end)
    for i in plot_range:
        plt.subplot(3,1,1)
        plt.title('Lead I')
        plt.xlabel('Time (S)')
        plt.ylabel('Voltage (mV)')
        plt.plot(long_time[start:int(i)],long_filt_ecg[0][start:int(i)])
        plot_points(long_filt_ecg[0], index, long_time, start, int(i))
        
        if int(i/fs) - 2 >= 0:
            plt.xlim(int(i)/fs-2,int(i)/fs)
        else:
            plt.xlim(time[0],time[-1])
            
        plt.subplot(3,1,2)
        plt.title('Lead II')
        plt.xlabel('Time (S)')
        plt.ylabel('Voltage (mV)')
        plt.plot(long_time[start:int(i)],long_filt_ecg[1][start:int(i)])
        plot_points(long_filt_ecg[1], index, long_time, start, int(i))
        
        if int(i/fs) - 2 >= 0:
            plt.xlim(int(i)/fs-2,int(i)/fs)
        else:
            plt.xlim(time[0],time[-1])
            
        plt.subplot(3,1,3)
        plt.title('Lead III')
        plt.xlabel('Time (S)')
        plt.ylabel('Voltage (mV)')
        plt.plot(long_time[start:int(i)],long_filt_ecg[2][start:int(i)]) 
        plot_points(long_filt_ecg[2], index, long_time, start, int(i))
        
        if int(i/fs) - 2 >= 0:
            plt.xlim(int(i)/fs-2,int(i)/fs)
        else:
            plt.xlim(time[0],time[-1])
            
        plt.pause(0.1)
        
    
    plt.clf()
    plt.subplot(3,1,1)
    plt.title('Lead I')
    plt.xlabel('Time (S)')
    plt.ylabel('Voltage (mV)')
    plt.plot(long_time[start:end],long_filt_ecg[0][start:end])
    plot_points(long_filt_ecg[0], index, long_time, start, end)
    plt.xlim(int(plot_range[-1])/fs-2,int(plot_range[-1])/fs)

    plt.subplot(3,1,2)
    plt.title('Lead II')
    plt.xlabel('Time (S)')
    plt.ylabel('Voltage (mV)')
    plt.plot(long_time[start:end],long_filt_ecg[1][start:end])
    plot_points(long_filt_ecg[1], index, long_time, start, end)
    plt.xlim(int(plot_range[-1])/fs-2,int(plot_range[-1])/fs)

    plt.subplot(3,1,3)
    plt.title('Lead III')
    plt.xlabel('Time (S)')
    plt.ylabel('Voltage (mV)')
    plt.plot(long_time[start:end],long_filt_ecg[2][start:end])
    plot_points(long_filt_ecg[2], index, long_time, start, end)
    plt.xlim(int(plot_range[-1])/fs-2,int(plot_range[-1])/fs)
    