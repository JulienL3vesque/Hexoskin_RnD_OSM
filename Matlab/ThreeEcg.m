% This is the Main Script that needes to be run
% Before proceeding check make sure that the ECG folders that will be run
% is in the same directory as the script
clc;
clear;
% Name of the ECG folder
FileName1    = 'ECG_I.csv';
FileName2    = 'ECG_II.csv';
FileName3    = 'ECG_III.csv';
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
LongEcg1 = [];
LongEcg2 = [];
LongEcg3 = [];
% Saves the whole filtered ECG signal
LongFilteredEcg1 = [];
LongFilteredEcg2 = [];
LongFilteredEcg3 = [];
% Saves the whole first derivative of ECG signal
LongEcg1D1 = [];
LongEcg2D1 = [];
LongEcg3D1 = [];
% Saves the whole second derivative of ECG signal
LongEcg1D2 = [];
LongEcg2D2 = [];
LongEcg3D2 = [];
% Saves the quality of all the R waves
LongRQuality = [];
% Used to save the ending of the ECG signal in case of a change
NewEnd = [];
% Saves the length of the ECG signal
EcgLength = [];
% Saves the warnings and the location
Warnings1 = cell(0,0);
Warnings2 = cell(0,0);
Warnings3 = cell(0,0);
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
Buffer1 = struct('Plot',[],'PlotD1',[],'PlotD2',[],'Long',[],'LongD1',...
    [],'LongD2',[],'Base',[],'BaseD1',[],'BaseD2',[],'Time',[]); 
Buffer2 = struct('Plot',[],'PlotD1',[],'PlotD2',[],'Long',[],'LongD1',...
    [],'LongD2',[],'Base',[],'BaseD1',[],'BaseD2',[],'Time',[]); 
Buffer3 = struct('Plot',[],'PlotD1',[],'PlotD2',[],'Long',[],'LongD1',...
    [],'LongD2',[],'Base',[],'BaseD1',[],'BaseD2',[],'Time',[]); 

% Stores intervals lengths
Interval1 = struct('RR',[],'RRIndex',[],'PR',[],'PRIndex',[],'QT',[],...
    'QTIndex',[], 'QTc',[]);
Interval2 = struct('RR',[],'RRIndex',[],'PR',[],'PRIndex',[],'QT',[],...
    'QTIndex',[], 'QTc',[]);
Interval3 = struct('RR',[],'RRIndex',[],'PR',[],'PRIndex',[],'QT',[],...
    'QTIndex',[], 'QTc',[]);
% Stores segments lengths
Segment1  = struct('PR',[],'PRIndex',[],'ST',[],'STIndex',[],'QRS',[],...
    'QRSIndex',[]);
Segment2  = struct('PR',[],'PRIndex',[],'ST',[],'STIndex',[],'QRS',[],...
    'QRSIndex',[]);
Segment3  = struct('PR',[],'PRIndex',[],'ST',[],'STIndex',[],'QRS',[],...
    'QRSIndex',[]);
% Stores certain calculated values
Value1    = struct('AverageST',[],'STIndex',[],'IsoIndex',[],'Iso',[],...
    'STMeasurement',[]);
Value2    = struct('AverageST',[],'STIndex',[],'IsoIndex',[],'Iso',[],...
    'STMeasurement',[]);
Value3    = struct('AverageST',[],'STIndex',[],'IsoIndex',[],'Iso',[],...
    'STMeasurement',[]);
% Stores duration
Duration1 = struct('P',[],'T',[]);
Duration2 = struct('P',[],'T',[]);
Duration3 = struct('P',[],'T',[]);
% Counters used in Calculation to keep track of the location
Count1 = struct('P',0,'T',0,'PRP',0,'PRQ',0,'PR',0,'QTQ',0,'QTT',0,'QT',...
0,'PRSP',0,'PRSQ',0,'PRS',0,'STSS',0,'STST',0,'STS',0,'QRSQ',0,'QRSS',...
0,'QRS',0,'IsoT',0,'IsoP',0,'Iso',0);
Count2 = struct('P',0,'T',0,'PRP',0,'PRQ',0,'PR',0,'QTQ',0,'QTT',0,'QT',...
0,'PRSP',0,'PRSQ',0,'PRS',0,'STSS',0,'STST',0,'STS',0,'QRSQ',0,'QRSS',...
0,'QRS',0,'IsoT',0,'IsoP',0,'Iso',0);
Count3 = struct('P',0,'T',0,'PRP',0,'PRQ',0,'PR',0,'QTQ',0,'QTT',0,'QT',...
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
[Ecg1, RIndex, RQuality, NewEnd,Time,AllFile] = ReadEcg(FileName1, RQualityFile,...
    EcgStart, EcgEnd, fs,AllFile);

[Ecg2, ~, ~, ~,~,~] = ReadEcg(FileName2, RQualityFile,...
    EcgStart, NewEnd, fs,AllFile);

[Ecg3, ~, ~, ~,~,~] = ReadEcg(FileName3, RQualityFile,...
    EcgStart, NewEnd, fs,AllFile);

EcgLength = length(Ecg1);

% Store the whole ECG in one array
LongEcg1 = [LongEcg1 Ecg1];
LongEcg2 = [LongEcg2 Ecg2];
LongEcg3 = [LongEcg3 Ecg3];
% Store the Time of the ECG
Buffer1.Time = [Buffer1.Time Time];
Buffer2.Time = [Buffer2.Time Time];
Buffer3.Time = [Buffer3.Time Time];

% Change to vertical before filtering
Ecg1 = Ecg1';
Ecg2 = Ecg2';
Ecg3 = Ecg3';

% If the LongEcg is more than 10 seconds then we can filter using 10
% seconds of data instead of 2 this will improve accuracy
if length(LongEcg1) > fs*10
    LongEcg1 = LongEcg1';
    LongEcg2 = LongEcg2';
    LongEcg3 = LongEcg3';
    Temp = FilterEcg(LongEcg1(end-10*fs +1:end),fs,IsAstro);
    LongEcg1 = LongEcg1';
    Ecg1 = Temp(end-EcgLength+1:end);
    
    Temp = FilterEcg(LongEcg2(end-10*fs +1:end),fs,IsAstro);
    LongEcg2 = LongEcg2';
    Ecg2 = Temp(end-EcgLength+1:end);
    
    Temp = FilterEcg(LongEcg3(end-10*fs +1:end),fs,IsAstro);
    LongEcg3 = LongEcg3';
    Ecg3 = Temp(end-EcgLength+1:end);
else
    Ecg1 = FilterEcg(Ecg1,fs,IsAstro);
    Ecg2 = FilterEcg(Ecg2,fs,IsAstro);
    Ecg3 = FilterEcg(Ecg3,fs,IsAstro);
end

% Save the filtered ECG
LongFilteredEcg1 = [LongFilteredEcg1 Ecg1];
LongFilteredEcg2 = [LongFilteredEcg2 Ecg2];
LongFilteredEcg3 = [LongFilteredEcg3 Ecg3];

% Since we rounded the R wave after transforming it from seconds to index
% The rounding might give us a lower value than the peak
% thats why we loop through the R waves and select the 
% index with the highest value from the adjacent points  
 for i = 1:length(RIndex)
     Range = RIndex(i) - 6:RIndex(i) + 6;
     if Range(end) > length(LongFilteredEcg1)
         Range = RIndex(i) - 10:length(LongFilteredEcg1);
     end
     
     [~,Temp] = max(LongFilteredEcg1(Range));
     RIndex(i) = Temp + Range(1) - 1;
 end

% Save R index
Index.R      = [Index.R RIndex'];
% Save R Quality
LongRQuality = [LongRQuality RQuality'];

% Apply derivative to ECG
Ecg1D1 = Derivative(Ecg1 ,fs);
Ecg2D1 = Derivative(Ecg2 ,fs);
Ecg3D1 = Derivative(Ecg3 ,fs);
% Apply double derivative to ECG
Ecg1D2 = Derivative(Ecg1D1,fs);
Ecg2D2 = Derivative(Ecg2D1,fs);
Ecg3D2 = Derivative(Ecg3D1,fs);

% Save derivatives
LongEcg1D1 = [LongEcg1D1 Ecg1D1];
LongEcg1D2 = [LongEcg1D2 Ecg1D2];

LongEcg2D1 = [LongEcg2D1 Ecg2D1];
LongEcg2D2 = [LongEcg2D2 Ecg2D2];

LongEcg3D1 = [LongEcg3D1 Ecg3D1];
LongEcg3D2 = [LongEcg3D2 Ecg3D2];

%% Save data to be used for detection

% Save the data in Buffer
Buffer1.Plot = LongFilteredEcg1;
Buffer1.PlotD1 = LongEcg1D1;
Buffer1.PlotD2 = LongEcg1D2;
Buffer1.Long = LongEcg1;

Buffer2.Plot = LongFilteredEcg2;
Buffer2.PlotD1 = LongEcg2D1;
Buffer2.PlotD2 = LongEcg2D2;
Buffer2.Long = LongEcg2;

Buffer3.Plot = LongFilteredEcg3;
Buffer3.PlotD1 = LongEcg3D1;
Buffer3.PlotD2 = LongEcg3D2;
Buffer3.Long = LongEcg3;

% Detect the PQRST waves and when they start and end
[Index, Fail, ~] = NewDetect(fs, Index, Fail, Buffer1, RIndex,IsAstro,RealTime);

% Do calculations that will be used to determine the current health
[Interval1, Segment1, Value1, Duration1, Count1] = Calculation(Index, Fail,...
    fs, Buffer1, Interval1, Segment1, Value1, Duration1, Count1, IsAstro);

% Do calculations that will be used to determine the current health
[Interval2, Segment2, Value2, Duration2, Count2] = Calculation(Index, Fail,...
    fs, Buffer2, Interval2, Segment2, Value2, Duration2, Count2, IsAstro);

% Do calculations that will be used to determine the current health
[Interval3, Segment3, Value3, Duration3, Count3] = Calculation(Index, Fail,...
    fs, Buffer3, Interval3, Segment3, Value3, Duration3, Count3, IsAstro);


% Start and End of the plot
TimeStart = TimeEnd + 1;
TimeEnd = length(Buffer1.Plot) - 1;

% Save the data so they can be used in the GUI
setappdata(0,'TimeStart',TimeStart);
setappdata(0,'TimeEnd',TimeEnd);
setappdata(0,'Buffer1',Buffer1);
setappdata(0,'Index',Index);
setappdata(0,'fs',fs);
setappdata(0,'LongRQuality',LongRQuality);
setappdata(0,'Interval1',Interval1);
setappdata(0,'Segment1',Segment1);
setappdata(0,'Value1',Value1);
setappdata(0,'Warnings1',Warnings1);
setappdata(0,'RIndex',RIndex);
setappdata(0,'RealTime',RealTime);
% Run the Graphical User Interface (GUI)
%gui;

% Get the changes that were made to Warnings
Warnings1 = getappdata(0,'Warnings1');

% Determine the Warnings
Warnings1 = CheckHealthFun(Warnings1,Buffer1,Interval1,fs,RealTime,...
    EcgStart,RIndex,Index,LongRQuality,NewEnd,Segment1,Value1,Ecg1,Duration1,IsAstro,Fail);

Warnings2 = CheckHealthFun(Warnings2,Buffer2,Interval2,fs,RealTime,...
    EcgStart,RIndex,Index,LongRQuality,NewEnd,Segment2,Value2,Ecg2,Duration2,IsAstro,Fail);

Warnings3 = CheckHealthFun(Warnings3,Buffer3,Interval3,fs,RealTime,...
    EcgStart,RIndex,Index,LongRQuality,NewEnd,Segment3,Value3,Ecg3,Duration3,IsAstro,Fail);

% Save the warnings
%setappdata(0,'Warnings1',Warnings1);

% Check for an alert
%CheckAlert;



end
