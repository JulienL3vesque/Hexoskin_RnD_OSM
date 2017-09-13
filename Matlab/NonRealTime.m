% This is the Main Script that needes to be run for non real time analysis
% Before proceeding check make sure that the ECG folders that will be run
% is in the same directory as the script
clc;
clear;
% Name of the ECG folder
FileName     = 'ECG_II.csv';
% Name of the Quality folder
RQualityFile = 'RR_interval_quality.csv';
% Sampling Frequency
fs = 256;
% Specify that this is non-real time
RealTime = 0;

% This is a boolean used to specify if the data we have is from the
% AstroSkin or it is from another source
IsAstro = 1;
%% Initialize variables

% Count poor quality regions
NumPoorQuality = 0; 
% The mean of an ECG section
BufferMean = 0;
% Saves the whole ECG signal
LongEcg = [];
% Saves the whole filtered ECG signal
LongFilteredEcg = [];
% Saves the whole first derivative of ECG signal
LongEcgD1 = [];
% Saves the whole second derivative of ECG signal
LongEcgD2 = [];
% Saves the quality of all the R waves
LongRQuality = [];

% Saves the length of the ECG signal
EcgLength = [];
% Saves the warnings and the location
Warnings = cell(0,0);
% Saves the warnings that occur more than a certain amount and the location
ImportantWarnings = cell(0,0);
% Saves the warnings that cause an alert
DisplayedAlerts = cell(0,0);
% Save them so they can be used afterwards
setappdata(0,'ImportantWarnings',ImportantWarnings);
setappdata(0,'DisplayedAlerts',DisplayedAlerts);
% Where to start the plot
TimeStart = 0;
% Where to end the plot
TimeEnd = -1;

%% Initialize structures 

% Stores indices of points
Index = struct('Pon',[],'P',[],'Poff',[],'Qon',[],'Q',[],'R',[],'S',[],...
    'Soff',[],'Jpoint',[],'Ton',[],'T',[],'Toff',[],'Ind',0); 

% Stores fail vectors
Fail = struct('P',[],'Q',[],'S',[],'T',[]);

% Stores buffers
Buffer = struct('Plot',[],'PlotD1',[],'PlotD2',[],'Long',[],'LongD1',...
    [],'LongD2',[],'Base',[],'BaseD1',[],'BaseD2',[],'Time',[]); 

% Stores intervals lengths
Interval = struct('RR',[],'RRIndex',[],'PR',[],'PRIndex',[],'QT',[],...
    'QTIndex',[], 'QTc',[]);
% Stores segments lengths
Segment  = struct('PR',[],'PRIndex',[],'ST',[],'STIndex',[],'QRS',[],...
    'QRSIndex',[]);
% Stores certain calculated values
Value    = struct('AverageST',[],'STIndex',[],'IsoIndex',[],'Iso',[],...
    'STMeasurement',[]);
% Stores duration
Duration = struct('P',[],'T',[]);
% Counters used in Calculation to keep track of the location
Count = struct('P',0,'T',0,'PRP',0,'PRQ',0,'PR',0,'QTQ',0,'QTT',0,'QT',...
0,'PRSP',0,'PRSQ',0,'PRS',0,'STSS',0,'STST',0,'STS',0,'QRSQ',0,'QRSS',...
0,'QRS',0,'IsoT',0,'IsoP',0,'Iso',0);


%% Main loop - Used to break down the signal

% Read the whole signal
[Ecg, RIndex, RQuality, Time] = ReadAllEcg(FileName,RQualityFile,fs);






%{
LongEcg = [];NewEnd = [];
Section = 0;
EcgStart = 0;
AllFile = [];
% Filter the signal
while EcgStart < 6500*fs
Section = Section+1;

% Select the start time
EcgStart = (2)*(Section-1)*fs;

% If NewEnd was used then modify the Start to start from the last data read
if ~isempty(NewEnd)
   EcgStart = NewEnd + 1; 
end

% Determine the End
EcgEnd = EcgStart + 2*fs - 1;

% Read ECG data
[Ecg, RIndex, RQuality, NewEnd,Time,AllFile] = ReadEcg(FileName, RQualityFile,...
    EcgStart, EcgEnd, fs,AllFile);
EcgLength = length(Ecg);

% Store the whole ECG in one array
LongEcg = [LongEcg Ecg];
% Store the Time of the ECG
Buffer.Time = [Buffer.Time Time];

% Change to vertical before filtering
Ecg = Ecg';

% If the LongEcg is more than 10 seconds then we can filter using 10
% seconds of data instead of 2 this will improve accuracy
if length(LongEcg) > fs*10
    LongEcg = LongEcg';
    Temp = FilterEcg(LongEcg(end-10*fs +1:end),fs,IsAstro);
    LongEcg = LongEcg';
    Ecg = Temp(end-EcgLength+1:end);
else
    Ecg = FilterEcg(Ecg,fs,IsAstro);
end

% Save the filtered ECG
LongFilteredEcg = [LongFilteredEcg Ecg];

% Apply derivative to ECG
EcgD1 = Derivative(Ecg ,fs);
% Apply double derivative to ECG
EcgD2 = Derivative(EcgD1,fs);

% Since we rounded the R wave after transforming it from seconds to index
% The rounding might give us a lower value than the peak
% thats why we loop through the R waves and select the 
% index with the highest value from the adjacent points  
 for i = 1:length(RIndex)
     % Select the range of the search
     Range = RIndex(i) - 6:RIndex(i) + 6;
     % If range is more than the length of Ecg take smaller range
     if Range(end) > length(LongFilteredEcg)
         Range = RIndex(i) - 10:length(LongFilteredEcg);
     end
     % Get the index of the maximum
     [~,Temp] = max(LongFilteredEcg(Range));
     % Save good peak
     RIndex(i) = Temp + Range(1) - 1;
 end

% Save derivatives
LongEcgD1 = [LongEcgD1 EcgD1];
LongEcgD2 = [LongEcgD2 EcgD2];
LongRQuality = [LongRQuality RQuality'];
Index.R      = [Index.R RIndex'];
end
Ecg = LongFilteredEcg;
EcgD1 = LongEcgD1;
EcgD2 = LongEcgD2;
Buffer.Plot = LongFilteredEcg;
Buffer.PlotD1 = LongEcgD1;
Buffer.PlotD2 = LongEcgD2;
Buffer.Long = LongEcg;
%}



Ecg = FilterEcg(Ecg,fs,IsAstro);

% Since we rounded the R wave after transforming it from seconds to index
% The rounding might give us a lower value than the peak
% thats why we loop through the R waves and select the 
% index with the highest value from the adjacent points  
 for i = 1:length(RIndex)

     Range = RIndex(i) - 6:RIndex(i) + 6;
     if Range(end) > length(Ecg)
         Range = RIndex(i) - 10:length(Ecg);
     end
     
     [~,Temp] = max(Ecg(Range));
     RIndex(i) = Temp + Range(1) - 1;
     
 end
 
% Apply derivative to ECG
EcgD1 = Derivative(Ecg ,fs);
% Apply double derivative to ECG
EcgD2 = Derivative(EcgD1,fs);

% Save data in structure
% Although no plotting will occur the name Plot was used so the same
% functions for real time will be used
Buffer.Plot   = Ecg;
Buffer.PlotD1 = EcgD1;
Buffer.PlotD2 = EcgD2;

Buffer.Time   = Time;
Index.R = RIndex';
LongRQuality = RQuality;


% Detect the PQRST waves and when they start and end
[Index, Fail, Buffer] = NewDetect(fs, Index, Fail, Buffer, Index.R,IsAstro,RealTime);


% Do calculations that will be used to determine the current health
[Interval, Segment, Value, Duration, Count] = Calculation(Index, Fail,...
    fs, Buffer, Interval, Segment, Value, Duration, Count, IsAstro);
%{
i  =10;
while 1
    Time = ((i*fs:(i+2)*fs)/fs);
    plot(Time,Buffer.Plot(i*fs:(i+2)*fs));hold on;
    PlotPoints(i*fs, (i+2)*fs, Buffer, Index, fs, ...
        LongRQuality, Interval, Segment, Value, (i+2)*fs, Time,RIndex);
    i = i+2;

    waitforbuttonpress();
        clf();
end
%}
% Determine the Warnings
% Specify the time for CheckHealth
% The time is the whole signal's time
EcgStart = 0;
NewEnd   = length(Ecg)-1;

CheckHealth;

% Save the warnings
setappdata(0,'Warnings',Warnings);
setappdata(0,'fs',fs);
ImportantWarnings = SelectImportantWarnings(ImportantWarnings, Warnings,...
    fs, RealTime);
setappdata(0,'ImportantWarnings',ImportantWarnings);
% Check for an alert
setappdata(0,'Buffer',Buffer);
DisplayedAlerts = CheckAlert(Warnings,ImportantWarnings,...
    DisplayedAlerts,fs,RealTime,Buffer);

% Save the results
% Name of the file where the results will be saved
EndFileName = 'NonRealStatus';
PrintToExcel(Warnings,ImportantWarnings,DisplayedAlerts,Fail,EndFileName);

