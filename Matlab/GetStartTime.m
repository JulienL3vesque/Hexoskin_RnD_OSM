function [ StartTime ] = GetStartTime()
% This function gets the time in GMT
% Output:
% StartTime(1) = Year
% StartTime(2) = Month
% StartTime(3) = Day
% StartTime(4) = Hour
% StartTime(5) = Minute
% StartTime(6) = Second

% Get saved Start Time so we wont read the file more than once
StartTime = getappdata(0,'StartTime');

% If we have no Start Time saved then we need to read the file
if isempty(StartTime)
    % Allocate Memmory
    StartTime = zeros(1,6);

    % Read the statistics file
    [~,TextData] = xlsread('statistics.csv');
    % Get the date and time from the file
    DateTime = char(TextData(3,2));

    %%DELETE
    DateTime = '21/03/2017 15:25:12';%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    %%


    % DateTime is in the form DD/MM/YYYY HH:MM:SS PM
    % str2double used although we have no doubles because it is faster than
    % str2num
    StartTime(1) = str2double(DateTime(7:10));
    StartTime(2) = str2double(DateTime(4:5));
    StartTime(3) = str2double(DateTime(1:2));
    StartTime(4) = str2double(DateTime(12:13));
    StartTime(5) = str2double(DateTime(15:16));
    StartTime(6) = str2double(DateTime(18:19));

    % Save the time so we wont have to read the file more than once
    setappdata(0,'StartTime',StartTime);
end

end

