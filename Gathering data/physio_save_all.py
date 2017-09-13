# -*- coding: utf-8 -*-
"""
Created on Thu Jun 22 07:26:37 2017

@author: Mostafa Hammoud

This script is opens a folder containing multiple diseases, and open every 
folder and then saves the ECG along with a tag

NOTE: This script has to be changed for every folder
Currently it is being used for reading ptbdb
"""

import numpy as np
from ecg import qrs_detector
import save_functions
import pandas as pd
import os

big_file_name = r'C:\Users\MHammoud\Desktop\Physionet Data\ptbdb'

# Initialize the arrays
all_ecg_path    = []
all_header_path = []
all_ecg   = {}
all_disease_type = []
all_disease_number = []
all_peaks = {}
temp_content = []

# Set the sampling frequency
fs = 1000

# Get the names of the folders inside big_file_name
folder_names = save_functions.get_folders(big_file_name)
# Get the path of these folders
folder_paths = save_functions.get_path(big_file_name, folder_names)

# Loop through the folders
for z in folder_paths:
    
    if os.path.isdir(z):
    
        # Get the names of the files inside the folders 
        ecg_names = save_functions.get_folders(z)
        # Get the path of the files inside the folders 
        ecg_path = save_functions.get_path(z, ecg_names)
        
        header_path = []
        
        # Loop thorugh the files and select the header files
        for j in ecg_path:
            if len(j) > 4:
                if j[-4:] == '.hea':
                    header_path.append(j)
                    all_header_path.append(j)
                    
        # This is a temp array used to do the loop            
        temp = header_path.copy()
        
        # Check the disease we are working with
        for j in temp:
            with open(j) as f:
                content = f.readlines()
            #Remove whitespace characters like `\n` at the end of each line
            content = [x.strip() for x in content] 
    
            # content[22] contains the disease type
            if 'Healthy' in content[22]:
                disease_num = 0
            elif 'Myocardial infarction' in content[22]:
                disease_num = 1
    
            # In case we have a disease we dont want then use -100 as a number  
            # so we wont access it
            else:
                disease_num = -100
            # Set number of diseases.
            # Here since we want to add this data to another set of data we set 
            # num_of_disease = 2 to match the other data
            num_of_diseases = 2
            
            # If the disease number if more than -1, indicating that we dont  
            # want the case of -100
            if disease_num > -1:
                # Save the ECG signal
                all_ecg_path.append(j[:-4] + '.csv')
                # Save the disease number
                all_disease_number.append(disease_num)
            else:
                # If the disease we have is not what we want, then remove the 
                # path of the header file
                all_header_path.remove(j)

# Loop through the ECG paths and extract the ECG signals that we need
j = 0
for i in all_ecg_path:

    # Read the signal
    file = pd.read_csv(i, delimiter=',', header = None)
    # Convert to matrix for easier accessing
    file = file.as_matrix()
    # Take out Leads I II III
    all_ecg[j]   = file[:,0]
    all_ecg[j+1] = file[:,1]
    all_ecg[j+2] = file[:,2]
    
    # Change the frequency of the data to match the AstroSkin frequency = 256
    all_ecg[j]   = save_functions.change_freq(fs,256,all_ecg[j])
    all_ecg[j+1] = save_functions.change_freq(fs,256,all_ecg[j+1])
    all_ecg[j+2] = save_functions.change_freq(fs,256,all_ecg[j+2])
    
    # Increment j
    j+=3
    
   
# Loop through the ECG signals and store them
j = 0
for i in range(0,np.size(all_ecg_path)*3,3):
    # Indicate when to start and end
    start = 0
    end = len(all_ecg[i])
    # Initialize a set to store the three ECG leads
    three_ecg = {}
    
    # Get the disease_num we are working with
    disease_num = all_disease_number[j]
    
    # If the disease number is more than -1 indicating the disease we want, 
    # then save it
    if disease_num > -1:
        
        # Use Lead I to find the QRS complex
        # We need the QRS complex to separate the signal into heart beats
        all_peaks[j] = qrs_detector(256,all_ecg[i],filter_length = (end-start))
        
        # Save the three leads to three_ecg
        three_ecg[0] = all_ecg[i]
        three_ecg[1] = all_ecg[i+1]
        three_ecg[2] = all_ecg[i+2]
        
    
    
        # Specify what the last peak we need to take, this is added since the last 
        # few seconds are sometimes noisy, since it is recorded when the ECG is 
        # getting disconnected  
        end_peak = np.size(all_peaks[j]) - 4  
    
        # Save the ECG beats
        save_functions.save_ecg(all_peaks[j],three_ecg,256,num_of_diseases,all_disease_number[j],end_peak) 
        
        # Reinitialize to be used in next loop
        three_ecg    = {}
        all_peaks[j] = []
        all_ecg[j]   = []
        all_ecg[j+1] = []
        all_ecg[j+2] = []                                      
    j += 1
                      
