function [] = GraphAlert(Warnings,ImportantWarnings,InspectedWarning,...
    fs,DisplayedAlerts,Buffer)


for k = 0:2
    
    WarningIDs = GetWarnings(Warnings,InspectedWarning,...
        DisplayedAlerts{end-k,2},1,fs);
    
    figure();
    
   SortedLocation = zeros(1,length(WarningIDs));
   
   for z = 1:length(WarningIDs) 
       SortedLocation(z) = Warnings{WarningIDs(z),2};
   end

    SortedLocation = sort(SortedLocation);
    
    for z = 1:length(WarningIDs)
        
        WarningLocation = SortedLocation(z);
        
        Range = WarningLocation - 200:WarningLocation + 200;
        if Range(end) > length(Buffer.Plot);
            Range = WarningLocation - 200:length(Buffer.Plot);
        end
        
        subplot(length(WarningIDs),1,z);
        plot(Range/fs,Buffer.Plot(Range));hold on;
        
        % Only display the title on the first plot
        if z == 1
            title(InspectedWarning);
        end
        
        ylabel('Voltage(mV)');xlabel('time(sec)');
        plot(WarningLocation/fs,Buffer.Plot(WarningLocation),...
        'o','MarkerSize',10);
        hold off;
        
    end
end
end