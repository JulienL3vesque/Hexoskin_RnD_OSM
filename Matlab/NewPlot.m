function [Axis1] = NewPlot( TimeStart, TimeEnd, Buffer, Index, fs, ...
    LongRQuality, Interval, Segment, Value, handles,RIndex)
% Plot the ECG along with the detected Points

TimeStart = TimeStart-1;
Time = ((TimeStart)/fs:1/fs:(TimeEnd)/fs);

% Determine the speed of plotting
% The smaller the number the slower
Gap = 60;

% Begining of the plot
Start = 0;
% End of the plot
Finish = TimeStart/fs;

Range = TimeStart+1:Gap:TimeEnd+1;
if Range(end) < TimeEnd+1
    Range = [Range TimeEnd+1];
end

for i = Range

    
if TimeStart/fs <=1
    Start = 0;
    Finish = 2;
else
    Finish = Finish + (Gap/fs);
    Start = Finish - 2;
end

if TimeStart < 1
   TimeStart = 1; 
end

% Get the axis
Axis1 = handles.axes;
% Select where to plot
axes(Axis1);
grid on;
grid minor;
title('Lead II Filtered ECG');
xlabel('Time(sec)'),ylabel('mV');
    
Plot1 = plot(Time(1:i-TimeStart),Buffer.Plot(TimeStart+1 :i));
set(Plot1,'Color','b');
hold on;
xlim auto;

xlim( [Start Finish]);

PlotPoints( TimeStart, TimeEnd, Buffer, Index, fs, ...
    LongRQuality, Interval, Segment, Value, i, Time,RIndex);

zoom on;

pause(0.001);


end

end

