# -*- coding: utf-8 -*-
"""
Created on Thu Aug  3 14:56:34 2017

@author: Mostafa Hammoud

This function saves the warnings to an excel file
"""

import xlsxwriter
def save_excel(disp_warning1, disp_warning2, disp_warning3, index):
    
    wb = xlsxwriter.Workbook("output.xlsx")
    sheet1 = wb.add_worksheet("Sheet 1")
    
    sheet1.write(0,1,"Lead I")
    sheet1.write(1,0,"Warnings")
    sheet1.write(1,1,"Location")
    sheet1.write(1,2,"Time")
    
    sheet1.write(0,5,"Lead II")
    sheet1.write(1,4,"Warnings")
    sheet1.write(1,5,"Location")
    sheet1.write(1,6,"Time")
    
    sheet1.write(0,9,"Lead III")
    sheet1.write(1,8,"Warnings")
    sheet1.write(1,9,"Location")
    sheet1.write(1,10,"Time")
    
    sheet1.set_column(0,0,20)
    sheet1.set_column(4,4,20)
    sheet1.set_column(8,8,20)
    
    for i in range(len(disp_warning1)):
        sheet1.write(i+2,1,index.r[disp_warning1[i][0][0]])
        sheet1.write(i+2,0,disp_warning1[i][1])
        sheet1.write(i+2,2,index.r[disp_warning1[i][0][0]]/256)

    for i in range(len(disp_warning2)):
        sheet1.write(i+2,5,index.r[disp_warning2[i][0][0]])
        sheet1.write(i+2,4,disp_warning2[i][1])
        sheet1.write(i+2,6,index.r[disp_warning2[i][0][0]]/256)

    for i in range(len(disp_warning3)):
        sheet1.write(i+2,9,index.r[disp_warning3[i][0][0]])
        sheet1.write(i+2,8,disp_warning3[i][1])
        sheet1.write(i+2,10,index.r[disp_warning3[i][0][0]]/256)

    wb.close()
    
