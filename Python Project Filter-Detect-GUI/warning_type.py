# -*- coding: utf-8 -*-
"""
Created on Wed Jul 19 07:45:34 2017

@author: Mostafa Hammoud

This script contains the names of the warnings
"""

def warning_type(number):
    
    if number == 0:
        warning_name = 'Irregular Heart Rate'
    elif number == 1:
        warning_name = 'Abnornal P Wave'
    elif number == 2:
        warning_name = 'Abnornal R Wave'
    elif number == 3:
        warning_name = 'Abnornal T Wave'
    elif number == 4:
        warning_name = 'Long P Wave'
    elif number == 5:
        warning_name = 'High P Wave'
    elif number == 6:
        warning_name = 'High T Wave'
    elif number == 7:
        warning_name = 'Long QRS Segment'
    elif number == 8:
        warning_name = 'Short QRS Segment'
    elif number == 9:
        warning_name = 'Long PR Interval'
    elif number == 10:
        warning_name = 'Short PR Interval'
    elif number == 11:
        warning_name = 'Long QTc Interval'
    elif number == 12:
        warning_name = 'Short QTc Interval'
    elif number == 13:
        warning_name = 'ST Elevation'
    elif number == 14:
        warning_name = 'ST Depression'
    elif number == 15:
        warning_name = 'Significant Q wave'
    elif number == 16:
        warning_name = 'Inverted T wave'
    elif number == 17:
        warning_name = 'Fast Heart Rate during the morning'
    elif number == 18:
        warning_name = 'Myocardial Infaction'
    elif number == 19:
        warning_name = 'Significant S wave'
    elif number == 20:
        warning_name = 'Low P Wave'
    elif number == 21:
        warning_name = 'Low Q Wave'
    elif number == 22:
        warning_name = 'Missed Q Wave'
    elif number == 23:
        warning_name = 'Missed P Wave'
    elif number == 24:
        warning_name = 'Low S'
    # If the number specified is out of bound return an error message
    else:
        warning_name = []
        print('Invalid Warning Number') 
      
    return  warning_name



high_p       = warning_type(5)
high_t       = warning_type(6)
low_q        = warning_type(21)
low_p        = warning_type(20)
low_s        = warning_type(24)
sig_q        = warning_type(15)
sig_s        = warning_type(19)
inverted_t   = warning_type(16)
long_p       = warning_type(4)
long_qtc     = warning_type(11)
shirt_qrs    = warning_type(8)
st_elev      = warning_type(13)
irregular_hr = warning_type(0)

num_of_warnings = 25
