function [ CurrentTime ] = GetCurrentTime( Buffer )
% This function calculates the current time in seconds in a day 

% Time that passed after the recording started(in sec)
TimeElapsed = Buffer.Time(end);

% Get the start time
StartTime = GetStartTime();

Hour = StartTime(4); 
Minute = StartTime(5);
Second = StartTime(6);

% Calculate the current time in seconds
CurrentTime = TimeElapsed + Hour*3600 + Minute*60 + Second;

DaysPassed = floor(CurrentTime/(24*3600));

% CurrentTime contains only hours of one day
CurrentTime = CurrentTime - DaysPassed*3600; 

end

