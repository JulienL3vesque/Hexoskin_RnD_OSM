# -*- coding: utf-8 -*-
"""
Created on Thu Jun 22 07:26:37 2017

@author: Mostafa Hammoud

This script is opens a folder containing multiple diseases, and open every 
folder and then saves the ECG

NOTE: This script is made for the Astroskin Data Only
Before running the script we need to have a folder that contains another 
folders/folder and every folder of these should have 
ECG_I.csv, ECG_II.csv, ECG_III.csv 

The name of the sub folders should include the names of the health condition or
else nothing will be save

Also to check the conditions go to save_function.py -> get_disease_num

In case of a modification to the number of diseases, change num_of_diseases
"""

import numpy as np
from ecg import qrs_detector
import save_functions

big_file_name = 'Getting Data\All Diseases'

# The number of diseases that we have 
num_of_diseases = 4

# Arrays that will store data
all_ecg_path = []
all_ecg = {}
all_peaks = {}

# The sampling frequqency
fs = 256

# Get the folders that are inside the big file
folder_names = save_functions.get_folders(big_file_name)
# Add the path to these folders
folder_paths = save_functions.get_path(big_file_name, folder_names)

# Loop through the folders and open each and get the ECG signals
for i in folder_paths:
    # Get the ECG names that are in a single folder
    ecg_names = save_functions.get_folders(i)
    # Add the path to the ECGs
    ecg_path = save_functions.get_path(i, ecg_names)
    # Loop thorugh the path and add them to all_ecg_path
    for j in ecg_path:
        all_ecg_path.append(j)
        
# Read the ECGs
all_ecg = save_functions.read_all(all_ecg_path)
    
# Loop thorugh the ECGs and get the R location and then save a range before
#  and after the beat 
j = 0
for i in range(0,len(all_ecg),3):
    # Start at the location zero
    start = 0
    # End when the all the length of the ECG
    end = len(all_ecg[i])
    
    three_ecg = {}
    
    # Find the R waves
    all_peaks[j] = qrs_detector(fs,all_ecg[i],filter_length = (end-start))
    
    # Save the realted ECGs(LeadI II III) in Three ECG
    three_ecg[0] = all_ecg[i]
    three_ecg[1] = all_ecg[i+1]
    three_ecg[2] = all_ecg[i+2]
    
    # Read the folder name and returns the number of the disease
    disease_num = save_functions.get_disease_num(folder_names[j])
    # End before the end of the peaks, since in some cases the last peaks are 
    # noisy since we disconnected the AstroSkin
    end_peak = np.size(all_peaks[j]) - 2   
    
    # Save the ECG only if it corresponds to a disease we are working with
    if disease_num > -1:
        # Save the ECGs
        save_functions.save_ecg(all_peaks[j],three_ecg,fs,num_of_diseases,disease_num,end_peak) 
              
    # Reset the arrays
    three_ecg    = {}
    all_peaks[j] = []
    all_ecg[j]   = []
    all_ecg[j+1] = []
    all_ecg[j+2] = []                                      
    j += 1
                      
