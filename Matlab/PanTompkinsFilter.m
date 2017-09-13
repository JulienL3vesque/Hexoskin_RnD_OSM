function [FiltData,DiffData,MoveData] = PanTompkinsFilter(data, fs,QRSmaxwidth)
% Filtering of data matrix according to proposed data
% processing of QRS-detection algorithm:
% Pan et al. 1985: A Real-Time QRS Detection Algorithm.
% IEEE Trans Bio Eng. Vol. 32, No. 3, S.230-236
%
% Compared to the original proposed filtering, all filtering is replaced by 
% phase zero filtering.
%
% Impementation includes a powerline-bandstop-filter at 50 Hz, change this
% characteristic if necessary. Furthermore, the widest possible QRS-Complex 
% is initialized as having a duration of 150 ms. This could be adjusted as well. 
%
%
% input: - data: input-data of size MxN
%                M: amout of single input channels
%                N: single data channel length
%        - fs: data sampling-frequency
%        - QRSmaxwidth: expected maximal width for QRS complexes [ms]
%        NONE
% output:
%        - filt_dat: data after initial powerline and bandpass filtering
%        - diff_dat: filt_dat after smoothed differentation
%        - mov_dat:  diff_dat after moving window integration
%
% Released under the GNU General Public License
%
% Copyright (C) 2014  Daniel Wedekind
% Technichal University Dresden
% Faculty of Electrical and Computer Engineering
% Institute of Biomedical Engineering
% Cardiovascular Signal Processing Group
% Dresden, Germany, 2014
%
% daniel.wedekind@mailbox.tu-dresden.de
%
% Vers. 1.0:
% Last updated : 24-01-2014
%
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.


FiltData = zeros(size(data,1),size(data,2));
MoveData = zeros(size(data,1),size(data,2));
DiffData = zeros(size(data,1),size(data,2));

for index = 1:size(data,1)
%{
    Nfir = 100;
    %bandstop around 50 Hz
    powerline = 50; %Hz
    BS = fir1(Nfir,[(powerline-1) (powerline+1)].*2/fs,'stop');
    BSdata = filtfilt(BS,1,data(index,:));
    %cascaded highpass 5 Hz
    HP = fir1(Nfir,[5].*2/fs,'high');
    HPdata = filtfilt(HP,1,BSdata);
    %smooth differentatition
    SD = [-(1/6),-(1/6),0,(1/6),(1/6)];
    SDdata = filtfilt(SD,1,HPdata);
    %squaring
    SQdata = SDdata.^2;
    %moving window integration of 150ms
    windowL = QRSmaxwidth+1;
    MOV = ones (1,windowL)/windowL;
    MOVINT = filtfilt(MOV,1,SQdata);
    
    % Bandpass filter 0.5-25Hz
    f1 = 0.5;
    f2 = 25;
    Wn = [f1 f2]*2/fs;
    N = 3;
    [a,b] = butter(N,Wn);
    HPdata = filtfilt(a,b,HPdata);

    % Divide by standard deviation
    FiltData(index,:) = HPdata;
    %FiltData(index,:) = HPdata./std(HPdata);
    DiffData(index,:) = SDdata./std(SDdata);
    MoveData(index,:) = MOVINT./std(MOVINT);
    
   
    %}
    
   
    f1 = 0.5;
    f2 = 25;
    Wn = [f1 f2]*2/fs;
    N = 3;
    [a,b] = butter(N,Wn);
    FiltData = filtfilt(a,b,data(index,:));
   
    
    %FiltData = data(index,:);
    
end

return