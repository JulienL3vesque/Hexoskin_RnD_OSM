function [ Ecg,RLocation,RQuality,Time] = ReadAllEcg(FileName,...
    RQualityFile,fs)
% This function waits for data to be saved then reads it
% Inputs:
% FileName     : The name of the file containing ECG
% RFile        : The name of the file containing RR interval
% RQualityFile : The name of the file containing the quality of the R waves
%
% Outputs:
% Ecg      : ECG signal that is being read between EcgStart and EcgEnd
% RLocation: Location of the R waves 
% RQuality : Quality of the R waves

AllFile = csvread(FileName);
Ecg = AllFile(:,2);
Time = AllFile(:,1);
        
% Read the first column containing the time an R wave occurs
RWave = csvread(RQualityFile,1,0);
RLocation = RWave(:,1);
        
% Read the second column containing the quality of the R waves
RQuality = RWave(:,2);

% Change RLocation to position instead of time
RLocation = (RLocation*fs);

RLocation = round(RLocation);

end

