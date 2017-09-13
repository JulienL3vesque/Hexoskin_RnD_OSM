# -*- coding: utf-8 -*-
"""
Created on Thu Jun 22 09:39:20 2017

@author: Mostafa Hammoud

This script contains different functions that are used to save heart beats
"""

import numpy as np
import pandas as pd
from os import listdir
from os.path import isfile

"""
This function splits the ECG into beats and saves it in a Matrix
Change the name of the Matrix in case you dont want to write over the same 
Matrix
"""
def save_ecg(index,three_ecg,fs,num_of_diseases,disease_num,end_peak):

    # Check if we have a .npy that we need to add data to. If yes load it else 
    # create a new one
    
    # Name of the npy file that will store the 3D Matrix
    name_3d = "TESTING_PHYSIO_DATA_MI.npy"
    # Name of the npy file that will store the 2D Matrix
    name_2d = "LABEL_TESTING_PHYSIO_DATA_MI.npy"
    
    if isfile(name_3d):
        mat_3d = np.load(name_3d)
        mat_2d = np.load(name_2d)
    else:
        mat_3d = np.empty((3,204,0))
        mat_2d = np.empty((num_of_diseases,0))
    
    # Create the disease arrat    
    disease = np.zeros(num_of_diseases)
    # Based on the number of the disease add a one in the correct location
    if disease_num > -1:
        disease[disease_num] = 1
    
    # Loop throught the peaks and select a round(0.4*fs) range before and after
    # each peak. This range will be saved
    for i in range(2,end_peak):
        # Create the range
        plot_range = range(index[i] - round(0.4*fs),index[i]+round(0.4*fs))
        
        if len(plot_range) > 2:
            # Add the heart beat to the 3D matrix
            mat_3d = np.dstack((mat_3d,[three_ecg[0][plot_range], 
                                        three_ecg[1][plot_range],
                                       three_ecg[2][plot_range]]))
    
            # Add the disease type to the 2D matrix
            if np.size(mat_2d) == 0:
                mat_2d = disease
            else:
                mat_2d = np.vstack([mat_2d,disease])
    # Save the Matricies  
    np.save(name_3d, mat_3d)  
    np.save(name_2d, mat_2d)
    
""" 
This function returns the disease number
"""
def get_disease_num(file_name):
    if "Healthy" in file_name:
        disease_num = 0
    elif "MI" in file_name:
        disease_num = 1
    elif "Atrial Fibrillation" in file_name:
        disease_num = 2    
    elif "AV" in file_name:
        disease_num = 3        
    else:
        disease_num =  -100
        
    return disease_num

"""
This function gives the name of all the files in side the folder selected
"""
def get_folders(folder_name):
    file_names = [f for f in listdir(folder_name) ]
    return file_names
"""
This function returns an array with the path of the files inside a folder
"""
def get_path(big_folder_path, file_names):
    file_paths = []
    for i in file_names:
        file_paths.append(big_folder_path + '\\' + i)

    return file_paths
"""
This function read all the ECG files using an array that contains their path
"""    
def read_all(all_ecg_path):
    
    all_ecg = {}
    j = 0
    for i in all_ecg_path:
    
        # Only read ECG data
        if 'ECG_I.csv' in i or 'ECG_II.csv' in i or 'ECG_III.csv' in i:
            file = pd.read_csv(i, delimiter=',', header = None)
            file = file.as_matrix()
            
            # If we are working with Lead III that was recorded by the  
            # AstroSkin we need to inverse the sign to get the real 
            # Lead III
            if 'ECG_III.csv' in i:
                file[:,1] = - file[:,1]
        
            all_ecg[j]  = file[:,1]
            
            j += 1
    
    return all_ecg

"""
This functions changes the frequency of an array

Input:
Old Frequency: old_freq
New Frequency: new_freq
Array to be modified: array
Output:
Modified Array: new_array
"""
def change_freq(old_freq, new_freq, array):
    
    # If both frequencies are the same do nothing
    if new_freq == old_freq:
        return array
    
    # The x-axis of the old array. Will only be used for the length
    x_old = np.linspace(0, len(array), len(array))
    # The new x-axis
    x_new = np.linspace(0, len(array), int(len(array)*new_freq/old_freq))
    
    # Create a new array with a modified frequency
    new_array = np.interp(x_new, x_old, array);
    
    return new_array
    
    