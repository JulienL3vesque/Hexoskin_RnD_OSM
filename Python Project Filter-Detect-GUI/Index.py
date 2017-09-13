# -*- coding: utf-8 -*-
"""
Created on Mon Jun  5 08:51:55 2017

@author: Mostafa Hammoud

This is a class that stores the indicies of the waves

"""
import numpy as np

class Index:
    
    def __init__(self):
        self.p    = []
        self.pon  = []
        self.poff = []
        self.q    = []
        self.qon  = []
        self.r    = []
        self.s    = []
        self.soff = []
        self.t    = []
        self.ton  = []
        self.toff = []
        
    def add_p (self, p_index, pon_index, poff_index):
        if np.size(p_index) > 0:
            p_index    = int(p_index   )
            pon_index  = int(pon_index )
            poff_index = int(poff_index)
            
        self.p.append(p_index)
        self.pon.append(pon_index)
        self.poff.append(poff_index)
        
    def add_q (self, q_index, qon_index):
        if np.size(q_index) > 0:
            q_index   = int(q_index  )
            qon_index = int(qon_index)
            
        self.q.append(q_index)
        self.qon.append(qon_index)
        
    def add_r (self, r_index):
        if np.size(r_index) > 0:
            r_index = int(r_index)
            
        self.r.append(r_index)
        
    def add_s (self, s_index, soff_index):
        if np.size(s_index) > 0:
            s_index    = int(s_index   )
            soff_index = int(soff_index)  
            
        self.s.append(s_index)
        self.soff.append(soff_index)
        
    def add_t (self, t_index, ton_index, toff_index):
        if np.size(t_index) > 0:
            t_index    = int(t_index   )
            ton_index  = int(ton_index )
            toff_index = int(toff_index)
            
        self.t.append(t_index)
        self.ton.append(ton_index)
        self.toff.append(toff_index)
        
"""
This is a class that contains boolen arrays to indicate if a wave was detected
"""       
class Pass:
    
    def __init__(self):
        self.p    = []
        self.q    = []
        self.s    = []
        self.t    = []
        
    def add_p (self, p_pass):
        self.p.append(p_pass)
        
    def add_q (self, q_pass):
        self.q.append(q_pass)
        
    def add_s (self, s_pass):
        self.s.append(s_pass)
        
    def add_t (self, t_pass):
        self.t.append(t_pass)
  
"""
This is a class that contains RR PR QT QTc Intervals
"""       
class Interval:
    
    def __init__(self):
        self.rr  = []
        self.pr  = []
        self.qt  = []
        self.qtc = []
        
    def add_rr  (self, rr_interval  ):
        self.rr .append(rr_interval )
        
    def add_pr  (self, pr_interval  ):
        self.pr .append(pr_interval )
        
    def add_qt  (self, qt_interval  ):
        self.qt .append(qt_interval )
        
    def add_qtc (self, qtc_interval ):
        self.qtc.append(qtc_interval)
        
"""
This is a class that contains PR ST Segments and QRS Complex
"""       
class Segment:
    
    def __init__(self):
        self.pr  = []
        self.st  = []
        self.qrs = []
        
    def add_pr  (self, pr_segment  ):
        self.pr .append(pr_segment )
        
    def add_st  (self, st_segment  ):
        self.st .append(st_segment )
        
    def add_qrs (self, qrs_segment ):
        self.qrs.append(qrs_segment) 
        
"""
This is a class that contains Average_ST ST_Index Iso_Index Iso ST_Measurement
"""       
class Value:
    
    def __init__(self):
        self.iso            = []
        self.average_st     = []
        self.st_measurement = []
        
    def add_average_st   (self, average_st ):
        self.average_st .append(average_st )
        
    def add_iso  (self, iso  ):
        self.iso .append(iso )
        
    def add_st_measurement (self, st_measurement ):
        self.st_measurement.append(st_measurement)
        
"""
This is a class that contains the duration of P and T waves
"""       
class Duration:
    
    def __init__(self):
        self.p  = []
        self.t  = []
        
    def add_p(self, p_duration  ):
        self.p.append(p_duration)
        
    def add_t(self, t_duration  ):
        self.t.append(t_duration)
        
