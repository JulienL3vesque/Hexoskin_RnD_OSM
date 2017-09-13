"""
Created on Thu May 25 13:06:32 2017

@author: Mostafa Hammoud

This function reads an ECG with a start and end location
"""
import pandas as pd
import time   as t

def read_ecg(file_name, start, end, fs):
    loop = 1
    # Keep looping until the loop breaks
    while(loop):
        # Read from file, start reading from start position and end after 
        # (end - start)
        file = pd.read_csv(file_name, delimiter=',', skiprows = start,
                           nrows = (end-start), header = None)
                
        # Convert the file to a matrix so we can access it easily
        file = file.as_matrix()
            
        # Extract the time and ecg from the file
        time = file[:,0]
        ecg  = file[:,1]
        
        # Since lead 3 ecg has to be inverted
        if len(file_name) >= 11:
            if file_name[-11:] =='ECG_III.csv':
                ecg = - ecg
            
        # If we read the right amount then we can break
        if len (ecg) == (end - start):
            break
        # Else we have to wait for more data to come so we pause for some time
        else:
            loop += 1
            t.sleep(0.1)
            if loop > 100:
                print('Connection Problem')
                break
        
    return time, ecg