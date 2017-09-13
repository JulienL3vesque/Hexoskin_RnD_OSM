function [] = AlertFound(Warnings,ImportantWarnings,InspectedWarning,fs,...
     DisplayedAlerts,Buffer)
% This function displays the Alert

% Graph the alert
 GraphAlert(Warnings,ImportantWarnings,InspectedWarning,fs,...
     DisplayedAlerts,Buffer);

% Display a warning message
warndlg(sprintf('Alert Detected:\n%s\nPlease Verify',InspectedWarning));


%{
% Send an email
UserName = 'mostafa.hamm@gmail.com';
Password = 
EmailTo  = 'mostafa.hammoud@canada.ca';
Subject  = 'Alert Generated';
Content  = 'An alert has been generated please verify';
SendEmail(UserName,Password,EmailTo,Subject,Content);
%}

end