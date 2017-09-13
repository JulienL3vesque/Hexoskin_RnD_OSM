# -*- coding: utf-8 -*-
"""
Created on Fri Jul 28 08:28:43 2017

@author: Mostafa Hammoud

This is a the gui class used to start build a gui
"""
import sys
from PyQt5 import QtWidgets, QtGui
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use("Qt5Agg")
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT as NavigationToolbar
from matplotlib.figure import Figure
from plot_one import plot

all_ecg = {}

class Window(QtWidgets.QWidget):
    
    def __init__(self):
        
        super().__init__()
        self.all_filt_ecg = {}
        self.long_time = {}
        self.index = []
        self.time = []
        self.fs = 0
        self.init_ui()
        
    def init_ui(self):
        w = 1000; h = 800

        self.resize(w, h)
        
        self.setWindowIcon(QtGui.QIcon('ecg_logo.png'))
        self.b1 = QtWidgets.QPushButton('Pause')
        self.rb1 = QtWidgets.QRadioButton('Lead 1')
        self.rb2 = QtWidgets.QRadioButton('Lead 2')
        self.rb3 = QtWidgets.QRadioButton('Lead 3')
        self.list = QtWidgets.QListWidget()
        self.figure = plt.figure(num = -6,figsize=(10,3.8),)
        self.canvas = FigureCanvas(self.figure)
        self.canvas.setFixedHeight(379)
        self.toolbar = NavigationToolbar(self.canvas, self)
        
        self.b1.setFixedWidth(150)
        
        grid = QtWidgets.QGridLayout()
        grid.addWidget(self.canvas, 2, 0,1, 1)
        grid.addWidget(self.toolbar, 1, 0,1, 1)
        grid.addWidget(self.b1)
        grid.addWidget(self.rb1)
        grid.addWidget(self.rb2)
        grid.addWidget(self.rb3)
        grid.addWidget(self.list)
        
        self.rb1.setChecked(True)
        self.rb1.toggled.connect(self.rb1_toggle)
        self.rb2.toggled.connect(self.rb2_toggle)
        self.rb3.toggled.connect(self.rb3_toggle)
        
        self.list.doubleClicked.connect(self.list_clicked)
        
        
        self.setLayout(grid)
        self.setWindowTitle('ECG')
        
        self.b1.clicked.connect(self.btn1_click)
        
        self.show()
    
    def btn1_click(self):
        if self.b1.text() == "Pause":
            pause = True
            self.b1.setText('Unpause')
        else:
            pause = False
            self.b1.setText('Pause')
            return
        while pause:
            if self.b1.text() == "Pause":
                break
            plt.pause(0.1)
            

    def list_clicked(self):
        warning = (self.list.currentItem().text())
        location = (self.list.currentRow())
        
        if "Lead III" in warning:
            for i in self.all_disp_warnings[location][0]:
                plt.figure()
                plt.title(warning)
                plt.xlabel('Time (s)')
                plt.ylabel('Volts (mV)')
                plt.plot(self.long_time[self.index.r[i]-100:self.index.r[i]+100],self.all_filt_ecg[2][self.index.r[i]-100:self.index.r[i]+100])
        elif "Lead II" in warning:
            
            for i in self.disp_warning2[location][0]:
                plt.figure()
                plt.title(warning)
                plt.xlabel('Time (s)')
                plt.ylabel('Volts (mV)')
                plt.plot(self.long_time[self.index.r[i]-100:self.index.r[i]+100],self.all_filt_ecg[1][self.index.r[i]-100:self.index.r[i]+100])
            
        else:
            for i in self.all_disp_warnings[location][0]:
                plt.figure()
                plt.title(warning)
                plt.xlabel('Time (s)')
                plt.ylabel('Volts (mV)')
                plt.plot(self.long_time[self.index.r[i]-100:self.index.r[i]+100],self.all_filt_ecg[0][self.index.r[i]-100:self.index.r[i]+100])
        
    def add_warning(self, warning):
        new_item = QtWidgets.QListWidgetItem()
        new_item.setText(warning)
        if "ST Elevation" in warning:
            # The color yellow
            new_item.setBackground(QtGui.QBrush(QtGui.QColor(255,200,0)))
        self.list.addItem(new_item)
        
        
    def get_warnings(self):
        warnings_displayed = []
        for index in range(self.list.count()):
            warnings_displayed.append(self.list.item(index).text())
        return warnings_displayed
    
    def rb1_toggle(self):
        plt.cla()
    def rb2_toggle(self):
        plt.cla()
    def rb3_toggle(self):
        plt.cla()
    def plot_lead1(self):
        ecg_type = "Lead I"
        plot(self.all_filt_ecg[0], self.time, self.long_time, self.index, self.fs, self.canvas, ecg_type, self.figure)
        self.canvas.draw()
    
    def plot_lead2(self):
        ecg_type = "Lead II"
        plot(self.all_filt_ecg[1], self.time, self.long_time, self.index, self.fs, self.canvas, ecg_type, self.figure)
        self.canvas.draw()
        
    def plot_lead3(self):
        ecg_type = "Lead III"
        plot(self.all_filt_ecg[2], self.time, self.long_time, self.index, self.fs, self.canvas, ecg_type, self.figure)
        self.canvas.draw()
    
    def pass_ecg(self, all_filt_ecg):
        self.all_filt_ecg = all_filt_ecg
    def pass_long_time(self, long_time):
        self.long_time = long_time
    def pass_time(self, time):
        self.time = time
    def pass_index(self, index):
        self.index = index
    def pass_fs(self, fs):
        self.fs = fs
    def pass_disp_warning1(self, disp_warning1):
        self.disp_warning1 = disp_warning1
    def pass_disp_warning2(self, disp_warning2):
        self.disp_warning2 = disp_warning2
    def pass_disp_warning3(self, disp_warning3):
        self.disp_warning3 = disp_warning3
    def pass_all_disp_warnings(self, all_disp_warnings):
        self.all_disp_warnings = all_disp_warnings

""" 
app = QtWidgets.QApplication.instance()
if app is None:
    app = QtWidgets.QApplication(sys.argv)


a_window = Window()
a_window.add_warning('fs')

a_window.add_warning('FA')

a = a_window.get_warnings()
"""