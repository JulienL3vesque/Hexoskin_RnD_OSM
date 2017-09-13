function [ Ecg ] = FilterEcg( Ecg, fs, IsAstro)
% This function applies a filter to the ECG

% Setting the maximum width to 0.15*fs = 38 seconds
QRSMaxWidth = round(.15*fs);
% Boolean used to allow the inversion of the input channel
Verbose = true;

%% General signal preparation
% Baseline-wander

[BWb,BWa] = butter(5,[1.0].*2/fs,'high');
Ecg = filtfilt(BWb,BWa,Ecg);

% Normalization
if IsAstro
    Ecg  = Ecg/100;
end
%Ecg = Ecg./std(Ecg);

%% Treat case of negative QRS sign
%{
checkSign = sort(Ecg,'descend');

signFLAG = mean(abs(checkSign(length(Ecg)-round(0.1*length(checkSign)):length(Ecg))))...
    > mean(abs(checkSign(1:round(0.1*length(checkSign)))));

if (signFLAG) && Verbose        
     disp('input channel inverted due to possible negative QRS manifestation');
     Ecg = -Ecg;
end
%}
Ecg = Ecg';
%% applying pan tompkins filtering
% DiffData & MoveData are not being used by this code 
% But they are kept incase they can be helpful in the future
[Ecg,DiffData,MoveData] = PanTompkinsFilter(Ecg, fs,QRSMaxWidth);

end

