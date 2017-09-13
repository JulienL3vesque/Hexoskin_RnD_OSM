# -*- coding: utf-8 -*-
"""
Created on Tue Jul 18 09:23:26 2017

@author: Mostafa Hammoud

This function uses the interval, segment, and value to get the current health 
of the user.

Every Heart beat will have a corresponding warning associated with it.
If it is a normal heart beat the warninig will be []
"""
import numpy as np
import warning_type
def get_health(warning1, warning2, warning3, all_filt_ecg, index, duration,
               interval, segment, value1, value2, value3, fs, 
               modified_warning1, modified_warning2, modified_warning3,
               disp_warning1, disp_warning2, disp_warning3, all_disp_warnings):
    
    # Select where to start the loop
    begin = len(warning1)
    
    # Loop thought the peaks that haven't been checked yet
    for i in range(begin, len(index.r)):
        
        # Set the reference amplitude
        reference_amp1 = abs(all_filt_ecg[0][index.r[i]])
        reference_amp2 = abs(all_filt_ecg[1][index.r[i]])
        reference_amp3 = abs(all_filt_ecg[2][index.r[i]])
        
        peak_warning1 = []
        peak_warning2 = []
        peak_warning3 = []

        if np.size(index.p[i]) != 0:
            if all_filt_ecg[0][index.p[i]] > 0.3 * reference_amp1:
                peak_warning1.append(warning_type.high_p)
            elif all_filt_ecg[0][index.p[i]] < 0.1 * reference_amp1:
                 peak_warning1.append(warning_type.low_p)
            if all_filt_ecg[1][index.p[i]] > 0.3 * reference_amp2:
                peak_warning2.append(warning_type.high_p)
            elif all_filt_ecg[1][index.p[i]] < 0.1 * reference_amp2:
                peak_warning2.append(warning_type.low_p) 
            if all_filt_ecg[2][index.p[i]] > 0.3 * reference_amp3:
                peak_warning2.append(warning_type.high_p)
            elif all_filt_ecg[2][index.p[i]] < 0.1 * reference_amp3:
                peak_warning3.append(warning_type.low_p)
        else:
            peak_warning1.append(warning_type.low_p)
            peak_warning2.append(warning_type.low_p)    
            peak_warning3.append(warning_type.low_p)
            
        if np.size(index.q[i]) != 0:
            if abs(all_filt_ecg[0][index.q[i]]) > reference_amp1*0.4:
                peak_warning1.append(warning_type.sig_q)
            if abs(all_filt_ecg[1][index.q[i]]) > reference_amp2*0.4:
                peak_warning2.append(warning_type.sig_q)
            if abs(all_filt_ecg[2][index.q[i]]) > reference_amp3*0.4:
                peak_warning3.append(warning_type.sig_q)
                
            if abs(all_filt_ecg[0][index.q[i]]) < reference_amp1*0.05  :
                peak_warning1.append(warning_type.low_q)
            if abs(all_filt_ecg[1][index.q[i]]) < reference_amp2*0.05  :
                peak_warning2.append(warning_type.low_q)
            if abs(all_filt_ecg[2][index.q[i]]) < reference_amp3*0.05  :
                peak_warning3.append(warning_type.low_q)
        else:
            peak_warning1.append(warning_type.low_q)
            peak_warning2.append(warning_type.low_q)    
            peak_warning3.append(warning_type.low_q)
                  
        if np.size(index.s[i]) != 0:
            if abs(all_filt_ecg[0][index.s[i]]) > reference_amp1*0.7:
                peak_warning1.append(warning_type.sig_s)
            if abs(all_filt_ecg[1][index.s[i]]) > reference_amp2*0.7:
                peak_warning2.append(warning_type.sig_s)
            if abs(all_filt_ecg[2][index.s[i]]) > reference_amp3*0.7:
                peak_warning3.append(warning_type.sig_s)

            if abs(all_filt_ecg[0][index.s[i]]) < reference_amp1*0.1  :
                peak_warning1.append(warning_type.low_s)
            if abs(all_filt_ecg[1][index.s[i]]) < reference_amp2*0.1  :
                peak_warning2.append(warning_type.low_s)
            if abs(all_filt_ecg[2][index.s[i]]) < reference_amp3*0.1  :
                peak_warning3.append(warning_type.low_s)
                
        if np.size(index.t[i]) != 0:
            if abs(all_filt_ecg[0][index.t[i]]) > reference_amp1*0.5:
                peak_warning1.append(warning_type.high_t)
            if abs(all_filt_ecg[1][index.t[i]]) > reference_amp2*0.5:
                peak_warning2.append(warning_type.high_t)
            if abs(all_filt_ecg[2][index.t[i]]) > reference_amp3*0.5:
                peak_warning3.append(warning_type.high_t)
                
            if all_filt_ecg[0][index.t[i]] < -reference_amp1*0.3:
                peak_warning1.append(warning_type.inverted_t)
            if all_filt_ecg[1][index.t[i]] < -reference_amp2*0.3:
                peak_warning2.append(warning_type.inverted_t)
            if all_filt_ecg[2][index.t[i]] < -reference_amp3*0.3:
                peak_warning3.append(warning_type.inverted_t)
                
        if np.size(duration.p[i]) != 0:
            if duration.p[i] > (110*fs/1000):
                peak_warning1.append(warning_type.long_p)
                peak_warning2.append(warning_type.long_p)
                peak_warning3.append(warning_type.long_p)
            
        if np.size(interval.qtc[i]) != 0:
            if interval.qtc[i] > (500*fs/1000):
                if all_filt_ecg[0][index.t[i]] > 0.1:
                    peak_warning1.append(warning_type.long_qtc)
                    peak_warning2.append(warning_type.long_qtc)
                    peak_warning3.append(warning_type.long_qtc)
            
        if np.size(segment.qrs[i]) != 0:
            if segment.qrs[i] < (60*fs/1000):
                peak_warning1.append(warning_type.short_qrs)
                peak_warning2.append(warning_type.short_qrs)
                peak_warning3.append(warning_type.short_qrs)
            
        if np.size(value1.st_measurement[i]) != 0:
            if value1.st_measurement[i] > 0.06:
                peak_warning1.append(warning_type.st_elev)
                
        if np.size(value2.st_measurement[i]) != 0:
            if value2.st_measurement[i] > 0.1:
                peak_warning2.append(warning_type.st_elev)    
                
        if np.size(value3.st_measurement[i]) != 0:        
            if value3.st_measurement[i] > 0.06:
                peak_warning3.append(warning_type.st_elev)
                
        # RR is 1 less than the size of index
        # In some cases we might have a missed R waves so the RR interval might
        # look big in this case we check if RR > 1.7*average.
        # If it is then this is a missed beat
        if i < (len(index.r) - 1) :
            if np.size(interval.rr[i]) != 0:
                if len(interval.rr) >= 5:
                    average_rate = np.mean(interval.rr[-5:])
                    if (interval.rr[i] > 1.3*average_rate or interval.rr[i] <
                    0.7*average_rate) and interval.rr[i] < 1.7*average_rate:
                        peak_warning1.append(warning_type.irregular_hr)
                        peak_warning2.append(warning_type.irregular_hr)
                        peak_warning3.append(warning_type.irregular_hr)

        warning1.append(peak_warning1.copy())
        warning2.append(peak_warning2.copy())
        warning3.append(peak_warning3.copy())
        modified_warning1.append(peak_warning1.copy())
        modified_warning2.append(peak_warning2.copy())
        modified_warning3.append(peak_warning3.copy())
    
    # Only starts when we have detected 10 heart beats
    if len(warning1) > 10:
        # Loop through all warnings    
        for i in range(warning_type.num_of_warnings):
            # Loop thorugh the last 10 beats
            warning_to_check = warning_type.warning_type(i)
            occurance1 = 0
            location1  = []
            occurance2 = 0
            location2  = []
            occurance3 = 0
            location3  = []
            for j in range(len(warning1) - 10,len(warning1)):
                if warning_to_check in modified_warning1[j]:
                    occurance1 += 1
                    location1.append(j)
                if warning_to_check in modified_warning2[j]:
                    occurance2 += 1
                    location2.append(j)
                if warning_to_check in modified_warning3[j]:
                    occurance3 += 1
                    location3.append(j)
                    
            if occurance1 > 4:
                disp_warning1.append([location1,warning_to_check])
                all_disp_warnings.append([location1,warning_to_check])
                for k in location1:
                    modified_warning1[k].remove(warning_to_check)
            if occurance2 > 4:
                disp_warning2.append([location2,warning_to_check])
                all_disp_warnings.append([location2,warning_to_check])
                for k in location2:
                    modified_warning2[k].remove(warning_to_check)
            if occurance3 > 4:
                disp_warning3.append([location3,warning_to_check])
                all_disp_warnings.append([location3,warning_to_check])
                for k in location3:
                    modified_warning3[k].remove(warning_to_check)
                
              
            occurance1 = 0
            location1  = []
            occurance2 = 0
            location2  = []                
            occurance3 = 0
            location3  = []        
            