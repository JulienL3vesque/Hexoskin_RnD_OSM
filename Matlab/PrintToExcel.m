function [  ] = PrintToExcel( Warnings,ImportantWarnings,DisplayedAlerts,...
    Fail, EndFileName )
% This functions prints the final result to an excel file


% Header of sheet 1
Header1 = {'ImportantWarnings','Location','Time','',...
    'AlertsGenerated','Location','Time'};

% Header of sheet 2
Header2 = {'Warnings','Location','Time'};

% Header of sheet 3
Header3 = {'Missed P','Percentage Missed %','','Missed Q',...
    'Percentage Missed %','','Missed S','Percentage Missed %','',...
    'Missed T','Percentage Missed %','','Total Number of Peaks Detected'};

% Add the headers to the file
xlswrite(EndFileName,Header1,'Sheet1');
xlswrite(EndFileName,Header2,'Sheet2');
xlswrite(EndFileName,Header3,'Sheet3');

% Save the data in file
if ~isempty(Warnings)
    xlswrite(EndFileName,Warnings,'Sheet2','A2');
    % Convert to matrix to do calculation then convert back to cell
    Time = num2cell(cell2mat(Warnings(:,2))/256);
    xlswrite(EndFileName,Time,'Sheet2','C2');
end

if ~isempty(ImportantWarnings)
    xlswrite(EndFileName,ImportantWarnings,'Sheet1','A2');
    % Convert to matrix to do calculation then convert back to cell    
    Time = num2cell(cell2mat(ImportantWarnings(:,2))/256);
    xlswrite(EndFileName,Time,'Sheet1','C2');
end
if ~isempty(DisplayedAlerts)
    xlswrite(EndFileName,DisplayedAlerts,'Sheet1','E2');
    % Convert to matrix to do calculation then convert back to cell    
    Time = num2cell(cell2mat(DisplayedAlerts(:,2))/256);    
    xlswrite(EndFileName,Time,'Sheet1','G2');
end

P = 0;
Q = 0;
S = 0;
T = 0;

R = length(Fail.P);

for i = 1:length(Fail.P)
    if Fail.P(i) == 0;
        P = P + 1;
    end
    if Fail.Q(i) == 0;
        Q = Q + 1;
    end
    if Fail.S(i) == 0;
        S = S + 1;
    end
    if Fail.T(i) == 0;
        T = T + 1;
    end
end

xlswrite(EndFileName,P,'Sheet3','A2');
xlswrite(EndFileName,P*100/R,'Sheet3','B2');
xlswrite(EndFileName,Q,'Sheet3','D2');
xlswrite(EndFileName,Q*100/R,'Sheet3','E2');
xlswrite(EndFileName,S,'Sheet3','G2');
xlswrite(EndFileName,S*100/R,'Sheet3','H2');
xlswrite(EndFileName,T,'Sheet3','J2');
xlswrite(EndFileName,T*100/R,'Sheet3','K2');
xlswrite(EndFileName,R,'Sheet3','M2');

end

