function [ WarningName ] = WarningType( Number )
% This function returns the warning type by specifying the warning location
% IMPORTANT: Incase warnings have been added or removed from here, change
% WarningDefenitionScript and WarningWorthAlert
if Number == 1
    WarningName = 'Irregular Heart Rate';
elseif Number == 2
    WarningName = 'Abnornal P Wave';
elseif Number == 3
    WarningName = 'Abnornal R Wave';
elseif Number == 4
    WarningName = 'Abnornal T Wave';
elseif Number == 5
    WarningName = 'Long P Wave';
elseif Number == 6
    WarningName = 'High P Wave';
elseif Number == 7
    WarningName = 'High T Wave';
elseif Number == 8
    WarningName = 'Long QRS Segment';
elseif Number == 9
    WarningName = 'Short QRS Segment';
elseif Number == 10
    WarningName = 'Long PR Interval';
elseif Number == 11
    WarningName = 'Short PR Interval';
elseif Number == 12
    WarningName = 'Long QTc Interval';
elseif Number == 13
    WarningName = 'Short QTc Interval';
elseif Number == 14
    WarningName = 'ST Elevation';
elseif Number == 15
    WarningName = 'ST Depression'; 
elseif Number == 16
    WarningName = 'Significant Q wave';
elseif Number == 17
    WarningName = 'Inverted T wave';
elseif Number == 18
    WarningName = 'Fast Heart Rate during the morning';
elseif Number == 19
    WarningName = 'Myocardial Infaction';
elseif Number == 20
    WarningName = 'Significant S wave';
elseif Number == 21
    WarningName = 'Low P Wave';
elseif Number == 22
    WarningName = 'Low Q Wave';
elseif Number == 23
    WarningName = 'Missed Q Wave';
elseif Number == 24
    WarningName = 'Missed P Wave';
% If the number specified is out of bound return an error message
else
   msg = 'Invalid Warning Number'; 
   error(msg);
end

