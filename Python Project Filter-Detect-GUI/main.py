# -*- coding: utf-8 -*-
"""
Created on Thu May 26 08:27:43 2017

@author: Mostafa Hammoud

This is the main script
It pulls an ECG and does the peak detection then determines the health

IDEAL ECG:
                           R
                          /\
                         /  \                          T
           P            /    \                       _____
          ___          /      \                     /     \
         /   \        /        \                   /       \
    ____/     \__    /          \        _________/         \____
                 \  /            \      /
                  \/              \    /
                   Q               \  /
                                    \/
                                     S
                                    
This script follows the following order:
    1- Read Data
    2- Detect R waves
    3- Filter Data
    4- Detect PQST and where they start and end
    5- Calculate the intervals
    6- Determine the health
"""

from read_ecg  import read_ecg
from ecg import qrs_detector
#from scipy.signal import find_peaks_cwt
from Index import Index
from Index import Pass
from Index import Segment
from Index import Interval
from Index import Value
from Index import Duration
from detect_waves import detect_waves
from calculation import do_calculation
from get_health import get_health
from gui import Window
from PyQt5 import QtWidgets
from save_excel import save_excel

#import time as t
import sys
import numpy as np
import various_functions
import filter

# File that we need to read the data from
file_name = r'C:\Users\ACMS\Desktop\Python Project Filter-Detect-GUI\Bernie ill 2 min 18-04-2017'
# Sampling frequency
fs = 256

# Get the path of the ECGs from the file
ecg_path = various_functions.get_ecg_path(file_name)

# Initialize dictionaries
all_ecg = {}
all_filt_ecg = {}


# Initialize objects
index = Index()
found = Pass()
interval = Interval()
segment = Segment()
# For Lead I
value1 = Value()
# For Lead II
value2 = Value()
# For Lead III
value3 = Value()
duration = Duration()

# Initialize arrays and constants
k = 1
section  = 0
long_ecg = np.empty(0)
long_filt_ecg = np.empty(0)
long_time = np.empty(0)
long_smooth = np.empty(0)

# Initialize lists
# For Lead I
warning1 = []
modified_warning1 = []
# For Lead II
warning2 = []
modified_warning2 = []
# For Lead III
warning3 = []
modified_warning3 = []
# Warnings that should be displayed
# For Lead I
disp_warning1 = []
# For Lead II
disp_warning2 = []
# For Lead III
disp_warning3 = []
# FOr all Leads
all_disp_warnings = []
new_end  = []
peaks    = []
rr =[]

# Get the current Application
app = QtWidgets.QApplication.instance()
  
# If we have no current application then we initialize one
if app is None:
    app = QtWidgets.QApplication(sys.argv)
# Create an object of the class Window
a_window = Window()


# Keep looping, since we are working with real-time data
while(1):
    # Used to keep track of the loop
    section = section + 1
    # Indicates the beginning of the ECG
    start = 2*(section - 1)*(fs)         
    # In certain cases the end of th where we use 
    # new_ende ECG will change and thats
    if new_end:
        # start begins after the new_end
        start = new_end + 1
    # The end is initially 2 seconds after the start    
    end   = start + 2*fs - 1
    
    # Read 3 seconds of data to detect the peaks but only the first 2 seconds 
    # will be used
    time_peak, ecg_peak = read_ecg(ecg_path[0], start, end + fs, fs)
    
    if len (ecg_peak) != (end + fs - start):
            break
    
    # Read 3 seconds of LEAD II and LEAD III
    # Will be used when finding the IsoElectric baseline
    time_temp, ecg_peak_lead2 =  read_ecg(ecg_path[1], start, end + fs, fs)
    time_temp, ecg_peak_lead3 =  read_ecg(ecg_path[2], start, end + fs, fs)
    
    # In case we don't have enough data then we end the loop
    if len(ecg_peak) != (end+fs-start):
        break;
    
    # Detect the peaks
    all_peaks = qrs_detector(fs,ecg_peak,filter_length = (end-start + fs))
    # Change the location of the peaks to make sure they are indexed correctly
    all_peaks = np.array(all_peaks + start)
    
    # Take the ECG from the previously read ECG
    ecg  = ecg_peak[:-fs+1]
    time = time_peak[:-fs+1]
    
    # Select the peaks that are inside the range start to end
    peaks = various_functions.remove_unwanted(all_peaks, end, start, True)
    
    # Save the ECG to long_ecg
    long_ecg = np.append(long_ecg,ecg)
    long_time = np.append(long_time,time)
    
    # Set the new_end equal to the current end to update it
    new_end = end

    if len(peaks) > 0:

        # Find the difference between the peaks
        rr = np.diff(peaks);
        # Remove any rate that is not in this range not in a +- 30 range
        # Since sometimes we might have bad peaks that were detected
        rr = various_functions.remove_unwanted(rr, (np.mean(rr) + 30     ) 
                                               ,(np.mean(rr) - 30), False)
          
        if np.size(rr) > 0:
            # If we have two or more peaks then we have an rr 
            # We use it to find a window for the detection
            rr = np.mean(rr)
            t_window_end = np.round(rr*0.5)
            t_off_window = np.round(rr*0.14)
              
        else:
            # If we dont have enough peaks we use a standared window
            t_window_end = np.round(350*fs/1000)
            t_off_window = np.round(100*fs/1000)
              
        # If the last peak detected does not have enough data after it then we
        # need to read more data      
        if (peaks[-1] > np.ceil(new_end - t_window_end - t_off_window)):
            
            # Set a new_end
            new_end = int(np.ceil(peaks[-1] + t_window_end + t_off_window))
            
            # Find if any peaks were detected between the old end and the 
            # new_end                 
            temp_peak = []
            temp_peak = various_functions.remove_unwanted(all_peaks, new_end,
                                                          end+1, True)
            # If we found peaks then we need to reduce the window size since we
            # will not be using the whole length
            if len(temp_peak) > 0:
                t_windwow_end = np.round((temp_peak[0] - peaks[-1])*0.5)
                t_off_window  = np.round((temp_peak[0] - peaks[-1])*0.14)
                
            # Re-update the new_end since we might have changed the window size
            new_end = int(np.ceil(peaks[-1] + t_window_end + t_off_window))
              
            # Add more data to the ECG                 
            ecg = ecg_peak[:(new_end - start + 1)]
            time = time_peak[:(new_end - start + 1)]
            
            # Save the added data to the long_ecg
            long_ecg  = np.append(long_ecg,ecg_peak
                                  [(end-start):(new_end-start)])
            
            long_time = np.append(long_time,time_peak
                                  [(end-start):(new_end-start)])

    # Read the rest of the ECG        
    temp, ecg_lead2 = read_ecg(ecg_path[1], start, new_end+1, fs)
    temp, ecg_lead3 = read_ecg(ecg_path[2], start, new_end+1, fs)  
    
    # Save the ECGs in all_ecg
    all_ecg[0] = long_ecg
    if len(all_ecg) < 2:
        # If all_ecg is still empty, we cannot append
        all_ecg[1] = ecg_lead2
        all_ecg[2] = ecg_lead3
    else:
        all_ecg[1] = np.append(all_ecg[1],ecg_lead2)
        all_ecg[2] = np.append(all_ecg[2],ecg_lead3)     
    
    
    #  If we have more than 10 seconds of data then use the last 10 seconds for
    # the filter by using more data we get better results
    if len(all_ecg[0]) > 10*fs:
        # LEAD I
        filt_ecg = filter.filter(all_ecg[0][-10*fs:],fs)
        
        smooth_ecg = filter.smooth_curve(filt_ecg)
        
        filt_ecg = filt_ecg[-(new_end-start + 1):]
        
        smooth_ecg = smooth_ecg[-(new_end-start + 1):]
        
        long_smooth = np.append(long_smooth,smooth_ecg)
        
        if len(all_filt_ecg) < 1:
            all_filt_ecg[0] = filt_ecg
        else:
            all_filt_ecg[0] = np.append(all_filt_ecg[0],filt_ecg)
            
        # LEAD II
        filt_ecg = filter.filter(all_ecg[1][-10*fs:],fs)
        filt_ecg = filt_ecg[-(new_end-start + 1):]
        
        if len(all_filt_ecg) < 1:
            all_filt_ecg[1] = filt_ecg
        else:
            all_filt_ecg[1] = np.append(all_filt_ecg[1],filt_ecg)
            
        # LEAD III
        filt_ecg = filter.filter(all_ecg[2][-10*fs:],fs)
        filt_ecg = filt_ecg[-(new_end-start + 1):]
        
        if len(all_filt_ecg) < 1:
            all_filt_ecg[2] = filt_ecg
        else:
            all_filt_ecg[2] = np.append(all_filt_ecg[2],filt_ecg)
        
    # If we don't have 10 seconds then use the time we have
    else:
        all_filt_ecg[0] = filter.filter(all_ecg[0],fs)
        
        all_filt_ecg[1] = filter.filter(all_ecg[1],fs)
        
        all_filt_ecg[2] = filter.filter(all_ecg[2],fs)
                
        long_smooth = filter.smooth_curve(all_filt_ecg[0])
    
    
    # Fix the peaks to ensure they are on top of the curve
    peaks = various_functions.fix_r(peaks, all_filt_ecg[0])
    
    for i in peaks:
        index.add_r(i)

    detect_waves(long_smooth, index, peaks, found, fs)
    
    # Since the smooth ECG was used to detect the waves we need to adjust the
    # waves using the filtered ECG, since the smooth ECG is a bit shifted than 
    # the filtered ECG
    
    # Start index is the length of the indicies - current length of the peaks
    # End index is the full length of the indicies
    
    index.p = various_functions.fix_peaks(all_filt_ecg[0], index.p, 
                                          len(index.p) - len(peaks),
                                          len(index.p), peak = True)
    
    index.t = various_functions.fix_peaks(all_filt_ecg[0], index.t, 
                                          len(index.t) - len(peaks),
                                          len(index.t), peak = True)
    
    index.q = various_functions.fix_peaks(all_filt_ecg[0], index.q, 
                                          len(index.q) - len(peaks),
                                          len(index.q), trough = True)
    
    index.s = various_functions.fix_peaks(all_filt_ecg[0], index.s, 
                                          len(index.s) - len(peaks),
                                          len(index.s), trough = True)

    # Do the necessary calculations
    do_calculation(all_filt_ecg, index, found, fs, interval, segment, value1, 
                   value2, value3, duration, all_peaks, ecg_peak,
                   ecg_peak_lead2, ecg_peak_lead3, start, end)
    warning_disp_len1 = len(disp_warning1)
    warning_disp_len2 = len(disp_warning2)
    warning_disp_len3 = len(disp_warning3)
    # Determine the health of the user
    get_health(warning1, warning2, warning3, all_filt_ecg, index, duration,
               interval, segment, value1, value2, value3, fs,
               modified_warning1, modified_warning2, modified_warning3,
               disp_warning1, disp_warning2, disp_warning3, all_disp_warnings)
    
    for i in range(warning_disp_len1,len(disp_warning1)):
        a_window.add_warning(disp_warning1[i][1] + ' Lead I')
    for i in range(warning_disp_len2,len(disp_warning2)):
        a_window.add_warning(disp_warning2[i][1] + ' Lead II')
    for i in range(warning_disp_len3,len(disp_warning3)):
        a_window.add_warning(disp_warning3[i][1] + ' Lead III')
    
    a_window.pass_ecg(all_filt_ecg)
    a_window.pass_long_time(long_time)
    a_window.pass_time(time)
    a_window.pass_index(index)
    a_window.pass_fs(fs)
    if a_window.rb1.isChecked():
        a_window.plot_lead1()
    elif a_window.rb2.isChecked():
        a_window.plot_lead2()
    else:
        a_window.plot_lead3()
    
    a_window.pass_disp_warning1(disp_warning1)
    a_window.pass_disp_warning2(disp_warning2)
    a_window.pass_disp_warning3(disp_warning3)
    a_window.pass_all_disp_warnings(all_disp_warnings)
    
save_excel(disp_warning1, disp_warning2, disp_warning3, index)