% This is the Main Script that needes to be run
% Before proceeding check make sure that the ECG folders that will be run
% is in the same directory as the script
clc;
clear;
close all;

% Delete any open warning boxes
Temp = findall(0,'tag','Msgbox_Warning Dialog');
for i = 1:size(Temp)
    delete(Temp(i));
end

% Name of the ECG folder
FileName     = 'ECG_I.csv';
% Name of the Quality folder
RQualityFile = 'RR_interval_quality.csv';
% Sampling Frequency
fs = 256;
% Specify that we are running RealTime script
RealTime = 1;
%FileName = 'samples.csv';
%RQualityFile = 'Quality.csv';
%fs = 250;
AllFile = [];%**************************************************************

% This is a boolean used to specify if the data we have is from the
% AstroSkin or it is from another source
IsAstro = 1;
%% Initialize variables

% Count poor quality regions
NumPoorQuality = 0; 
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
% Used to save the ending of the ECG signal in case of a change
NewEnd = [];
% Saves the length of the ECG signal
EcgLength = [];
% Saves the warnings and the location
Warnings = cell(0,0);
% Saves the warnings that occur more than a certain amount and the location
ImportantWarnings = cell(0,0);
% Saves the warnings that cause an alert
DisplayedAlerts = cell(0,0);
% Save them so they can be used by GUI
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
Fail = struct('P',[],'Q',[],'S',[],'T',[],'Toff',[]);

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

Run = 1;
Section = 0;

while Run
% Counter to detect how many times this loop occured
Section = Section+1;

% Select the start time
EcgStart = (2)*(Section-1)*fs;

% If NewEnd was used then modify the Start to start from the last data read
if ~isempty(NewEnd)
   EcgStart = NewEnd + 1; 
end

% Determine the End
EcgEnd = EcgStart + 2*fs - 1;

% Save Fail to be used when saving data to excel
setappdata(0,'Fail',Fail);

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

% Since we rounded the R wave after transforming it from seconds to index
% The rounding might give us a lower value than the peak
% thats why we loop through the R waves and select the 
% index with the highest value from the adjacent points  
 for i = 1:length(RIndex)
     % If the R wave was the last point in the Ecg we cannot check.
     %{
     if RIndex(i) + 1 <= length(LongFilteredEcg)
        
         % Check with the second upcoming point
        if LongFilteredEcg(RIndex(i)) < LongFilteredEcg(RIndex(i)+2)
            RIndex(i) = RIndex(i) + 2;
            
        % Check with the second previous point
        elseif LongFilteredEcg(RIndex(i)) < LongFilteredEcg(RIndex(i) - 2)
            RIndex(i) = RIndex(i) - 2;
            
        % Check with the upcoming point
        elseif LongFilteredEcg(RIndex(i)) < LongFilteredEcg(RIndex(i)+1)
            RIndex(i) = RIndex(i) + 1;
            
        % Check with the previous point
        elseif LongFilteredEcg(RIndex(i)) < LongFilteredEcg(RIndex(i) - 1)
            RIndex(i) = RIndex(i) - 1;
        
        end
         
     end
     %}
     Range = RIndex(i) - 6:RIndex(i) + 6;
     if Range(end) > length(LongFilteredEcg)
         Range = RIndex(i) - 10:length(LongFilteredEcg);
     end
     
     [~,Temp] = max(LongFilteredEcg(Range));
     RIndex(i) = Temp + Range(1) - 1;
 end

% Save R index
Index.R      = [Index.R RIndex'];
% Save R Quality
LongRQuality = [LongRQuality RQuality'];

% Apply derivative to ECG
EcgD1 = Derivative(Ecg ,fs);
% Apply double derivative to ECG
EcgD2 = Derivative(EcgD1,fs);

% Save derivatives
LongEcgD1 = [LongEcgD1 EcgD1];
LongEcgD2 = [LongEcgD2 EcgD2];

%% Save data to be used for detection

% Save the data in Buffer
Buffer.Plot = LongFilteredEcg;
Buffer.PlotD1 = LongEcgD1;
Buffer.PlotD2 = LongEcgD2;
Buffer.Long = LongEcg;

% Detect the PQRST waves and when they start and end
[Index, Fail, Buffer] = NewDetect(fs, Index, Fail, Buffer, RIndex,IsAstro,RealTime);

% Do calculations that will be used to determine the current health
[Interval, Segment, Value, Duration, Count] = Calculation(Index, Fail,...
    fs, Buffer, Interval, Segment, Value, Duration, Count, IsAstro);

% Start and End of the plot
TimeStart = TimeEnd + 1;
TimeEnd = length(Buffer.Plot) - 1;

% Save the data so they can be used in the GUI
setappdata(0,'TimeStart',TimeStart);
setappdata(0,'TimeEnd',TimeEnd);
setappdata(0,'Buffer',Buffer);
setappdata(0,'Index',Index);
setappdata(0,'fs',fs);
setappdata(0,'LongRQuality',LongRQuality);
setappdata(0,'Interval',Interval);
setappdata(0,'Segment',Segment);
setappdata(0,'Value',Value);
setappdata(0,'Warnings',Warnings);
setappdata(0,'RIndex',RIndex);
setappdata(0,'RealTime',RealTime);
setappdata(0,'DisplayedAlerts',DisplayedAlerts);
% Run the Graphical User Interface (GUI)
gui;

% Get the changes that were made to Warnings
Warnings = getappdata(0,'Warnings');

% Determine the Warnings
[ Warnings ] = CheckHealthFun(Warnings,Buffer,Interval,fs,RealTime...
    ,EcgStart,RIndex,Index,LongRQuality,NewEnd,Segment,Value,Ecg,...
    Duration,IsAstro,Fail);

% Save the warnings
setappdata(0,'Warnings',Warnings);

% Check for an alert
[DisplayedAlerts] = CheckAlert(Warnings,ImportantWarnings,...
    DisplayedAlerts,fs,RealTime,Buffer);

% To synchronize with data
%pause(2);

end
