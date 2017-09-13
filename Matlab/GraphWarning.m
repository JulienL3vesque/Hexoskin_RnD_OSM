function [] = GraphWarning(Warnings,ImportantWarnings,fs,Buffer)
% This function displays the graphs when the user selects a warning
% The selected warning will be followed by similar warnings all 4 will be
% graphed


WarningID = get(handles.listbox,'Value');

WarningType = ImportantWarnings{WarningID,1};
WarningLocation = ImportantWarnings{WarningID,2};

WarningIDs = GetWarnings(Warnings,WarningType,WarningLocation,WarningID,fs);

f = figure();

SortedLocation = zeros(1,4);

for j = 1:length(WarningIDs)
    WarningLocation = Warnings{WarningIDs(j),2};
    SortedLocation(j) = WarningLocation;
end

SortedLocation = sort(SortedLocation);

for j = 1:length(WarningIDs)
        
    WarningLocation = SortedLocation(j);
        
    Range = WarningLocation - 200: WarningLocation + 200;
    if Range(end) > length(Buffer.Plot)
        Range = WarningLocation - 200:length(Buffer.Plot);
    end
       
    subplot(length(WarningIDs),1,j);
    plot(Range/fs,Buffer.Plot(Range));hold on;
       
    % Only display the title on the first plot
    if j ==1
        title(ImportantWarnings{WarningID,1});
    end
         
    ylabel('Voltage(mV)');xlabel('time(sec)');
    plot(WarningLocation/fs,Buffer.Plot(WarningLocation),...
        'o','MarkerSize',10);
    hold off;
        
end
end
