# -*- coding: utf-8 -*-
"""
Created on Wed Jun  7 11:46:37 2017

@author: Mostafa Hammoud

This function calculates the length of the relevant segments of the ECG

Inputs: 
index : Contains the indices of the PQRST waves
found : Determines whether a wave was detected or misssed
fs    : Sampling frequency
all_ecg    : Contains the Lead I II III filtered
interval   : Conatins RR PR QT QTc Intervals
segment    : Contains PR ST Segments and QRS Complex
value1     : Contains AverageST STIndex IsoIndex Iso STMeasurement of Lead I
value2     : Contains AverageST STIndex IsoIndex Iso STMeasurement of Lead II
value3     : Contains AverageST STIndex IsoIndex Iso STMeasurement of Lead III
duration   : Contains P and T waves durations
three_peaks: Contains the peaks detected in the 3 seconds
ecg_peak   : Contains the Lead I ecg that was used to find the 3 second peaks
start      : The beginnig of the segment
end        : The end of the segment
ecg_peak_lead2: Contains 3 second Lead II
ecg_peak_lead3: Contains 3 second Lead III

Outputs  :
interval : Conatins RR PR QT QTc Intervals 
segment  : Contains PR ST Segments and QRS Complex
value    : Contains AverageST STIndex IsoIndex Iso STMeasurement
duration : Contains P and T waves durations

Additional Comments:
If the value of any of these segments or intervals is [] then it
indicates a missed detection
RR Interval length  is one less than other elements length
"""

import numpy as np
import various_functions

def do_calculation(all_filt_ecg, index, found, fs, interval, segment, value1, 
                   value2, value3, duration, three_peaks, ecg_peak,
                   ecg_peak_lead2, ecg_peak_lead3, start, end):
    
    # Calculate the distance between two consecutive R waves
    # We recalculate for the whole signal since it requires almost no 
    # computation time
    if len(index.r) > 1:
        interval.rr = np.diff(index.r)
    else:
        interval.rr = []
    
    # Set the start index
    begin = len(duration.p)
 
    # Loop through the peaks and do the necessary calculations 
    for i in range(begin,len(index.r)):
        
        # Duration of P wave: poff - pon
        if np.size(index.p[i]) != 0:
            duration.add_p(index.poff[i] - index.pon[i])
        else:
            duration.add_p([])
            
        # Duration of T wave: ton - toff    
        if np.size(index.t[i]) != 0:
            duration.add_t(index.toff[i] - index.ton[i])
        else:
            duration.add_t([])
        
        # PR Interval: qon - pon 
        if np.size(index.p[i]) != 0 and np.size(index.q[i]) != 0:
            interval.add_pr(index.qon[i] - index.pon[i])
        else:
            interval.add_pr([])
        
        # QT Interval: qon - toff
        if np.size(index.q[i]) != 0 and np.size(index.t[i]) != 0:
            interval.add_qt(index.toff[i] - index.qon[i])
        else:
            interval.add_qt([])   
        
        # PR Segment: qon - poff
        if np.size(index.p[i]) != 0 and np.size(index.q[i]) != 0:
            segment.add_pr(index.qon[i] - index.poff[i])
        else:
            segment.add_pr([])
        
        # ST Segment: ton - soff
        if np.size(index.s[i]) != 0 and np.size(index.t[i]) != 0:
            segment.add_st(index.ton[i] - index.soff[i])
            
            st_range = range(index.soff[i],index.ton[i] + 1)
            
            if len(st_range) < 2:                
                value1.add_average_st(np.mean(all_filt_ecg[0][index.ton[i]]))
                value2.add_average_st(np.mean(all_filt_ecg[1][index.ton[i]]))
                value3.add_average_st(np.mean(all_filt_ecg[2][index.ton[i]]))
            else:
                # If Soff is close to S that means it isn't accurate so we will
                # try to fix it
                if index.soff[i] - index.s[i] < 6:
                    temp_start = int(index.soff[i]+index.ton[i])/2
                    st_range = range(int(temp_start),index.ton[i] + 1)
                    
                value1.add_average_st(np.mean(all_filt_ecg[0][st_range]))
                value2.add_average_st(np.mean(all_filt_ecg[1][st_range]))
                value3.add_average_st(np.mean(all_filt_ecg[2][st_range]))
        else:
            
            segment.add_st([])
            value1.add_average_st([])
            value2.add_average_st([])
            value3.add_average_st([])
        
        # QRS Complex(Segment): soff - qon 
        if np.size(index.q[i]) != 0 and np.size(index.s[i]) != 0:
            
            temp = index.soff[i] - index.qon[i]
            
            # In some cases soff and qon are not so accurate so we will use q
            # and s instead add a constant
            if temp > (120*fs/1000):
                temp = index.s[i] - index.q[i] + round(30*fs/1000)
                
            segment.add_qrs(temp)
            
        else:
            segment.add_qrs([])
         
        # Calculate the Iso interval. It is between the end of the current T 
        # wave and the P wave after it
        # Since for the last T wave we need a P wave that has not been found 
        # yet we will use the R wave and try and estimate the range
        
        # The case where we have both T and P
        if i < (len(index.r) - 1):
            
            if np.size(index.t[i]) != 0 and np.size(index.p[i+1]) != 0:
                
                iso_range = range(index.toff[i],index.pon[i+1] + 1)
                
                iso = np.mean(all_filt_ecg[0][iso_range])
                value1.add_iso(iso)
                iso = np.mean(all_filt_ecg[1][iso_range])
                value2.add_iso(iso)
                iso = np.mean(all_filt_ecg[2][iso_range])
                value3.add_iso(iso)
                
            else:
                value1.add_iso([])
                value2.add_iso([])
                value3.add_iso([])
          
        # The case where we dont have the P wave   
        else:
            
            # Use the peaks that were detected in the 3 second range
           last_peaks =  various_functions.remove_unwanted(three_peaks,
                                                           end, end + fs)
           
           if last_peaks != []:
               # calculate the RR range to get p offset widows
               rr = np.diff(three_peaks[:-2])
               
               if np.size(rr) > 0:
                   rr = np.mean(rr)
                   
                   p_window_start = int(np.round(rr*0.25))
                   pon_window     = int(np.round(rr*0.08))
                   
               else:
                   p_window_start = int(np.round(200*fs/1000))
                   pon_window     = int(np.round(60 *fs/1000))                   
                
               # Specify the Iso range which starts at the end of the T wave 
               # and ends at (R_index - P_window - Pon_window)
               iso_range = np.arange(index.toff[i] - start,last_peaks[0] - 
                                 p_window_start - pon_window - start)
               
               # If the Iso range is small or too big its not relaible
               if np.size(iso_range) > 2 and np.size(iso_range) < 80:
                   # Calculte the mean of the Iso range
                  value1.add_iso(np.mean(ecg_peak[iso_range]))
                  value2.add_iso(np.mean(ecg_peak_lead2[iso_range]))
                  value3.add_iso(np.mean(ecg_peak_lead3[iso_range]))
               else:
                   value1.add_iso([])
                   value2.add_iso([])
                   value3.add_iso([])
           else:
               value1.add_iso([])
               value2.add_iso([])
               value3.add_iso([])

        if np.size(value1.iso[i]) != 0 and np.size(segment.st[i]) != 0:
            value1.add_st_measurement(value1.average_st[i] - value1.iso[i])
            value2.add_st_measurement(value2.average_st[i] - value2.iso[i])
            value3.add_st_measurement(value3.average_st[i] - value3.iso[i])
        else:
            value1.add_st_measurement([])
            value2.add_st_measurement([])
            value3.add_st_measurement([])
            
    # Select the start for the QTc interval  
    begin = len(interval.qtc)
    
    # Loop through the QT interval and perfom Bazett's calculation
    # We need to use the RR interval for that
    for i in range(begin,len(interval.qt)):
        if len(interval.rr) >= 1:
            # Since RR interval is smaller than the QT interval
            # For the last QTc calculation we will use the last RR interval 
            # So the last RR interval will be used twice
            if i < len(interval.rr):
                interval.add_qtc(interval.qt[i]/np.sqrt(interval.rr[i]))
            else:
                interval.add_qtc(interval.qt[i]/np.sqrt(interval.rr[-1]))
                
        else:
            interval.add_qtc([])

          
            