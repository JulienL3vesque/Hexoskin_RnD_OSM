function [DisplayedAlerts] = CheckAlert(Warnings,ImportantWarnings,...
    DisplayedAlerts,fs,RealTime,Buffer)
% This function checks if we have to display and alert


Size = size(ImportantWarnings);
Size = Size(:,1);

if ~isempty(ImportantWarnings)
    
    % Sort ImportantWarnings by name
    SortedImportant = sortrows(ImportantWarnings,1);
    % The warning we are working with
    InspectedWarning = SortedImportant{1,1};
end
% The times a warning occured
Occurrence = 0;

% If we are working with real time we can only look at last 3 important
% warnings since they will get updated and we will look at all warnings as
% it runs further
% But with non real time we need to look at all important warnings since
% they dont get updated
if RealTime

for i = 1:Size
   
    % If the same warning occured and its not the end of the loop increase
    % Occurrence
    if strcmp(InspectedWarning,SortedImportant{i,1}) && ...
            i~=length(SortedImportant)
       Occurrence = Occurrence + 1;
    else
        
        Bool = 0;
        
        % If the end of the loop was reached and the warnings are the same
        % increment Occurrence
        if strcmp(InspectedWarning,SortedImportant{i,1})&&...
                i==length(SortedImportant)
            Occurrence = Occurrence + 1;
            % This boolean is used to indicate that we reached this point
            Bool = 1;
        end
        
        % If 3 or more important warnings are present
        if Occurrence > 2
            if Bool
                InspectedLocationStart = SortedImportant{i-2,2};
                InspectedLocationEnd   = SortedImportant{i,2};
            else
                InspectedLocationStart = SortedImportant{i-1-2,2};
                InspectedLocationEnd   = SortedImportant{i-1,2};
            end
            
            % Check if warnings appears in last 40 seconds
            if InspectedLocationEnd - InspectedLocationStart < (40*fs)...
                    && WarningWorthAlert(InspectedWarning)
                if ~(CheckSimilarAlert(DisplayedAlerts,InspectedWarning,...
                        InspectedLocationStart,fs))
                    % Save the last 3 Occurrences of the warning
                    for z = 0:2
                        DisplayedAlerts{end+1,1} = InspectedWarning;
                        if Bool
                        DisplayedAlerts{end,2} = SortedImportant{i-2+z,2};
                        else
                        DisplayedAlerts{end,2} = SortedImportant{i-2-1+z,2};    
                        end
                    end
                    setappdata(0,'DisplayedAlerts',DisplayedAlerts);
                    if RealTime
                        AlertFound(Warnings,ImportantWarnings,...
                            InspectedWarning,fs,DisplayedAlerts,Buffer);
                    end
                end
            end
        end
        
        % Start a new warning with new Occurrence
        Occurrence = 1;
        % Change the warning we are working with
        InspectedWarning = SortedImportant{i,1};
    end
end

else
% Loop through all warnings and check the warnings at positions 1&3, 2&4, 
% 3&5, .....      
for i = 1:Size-2
    
    % If two similar warnings are found then check where they occured
    if strcmp(SortedImportant{i,1},SortedImportant{i+2,1})
        InspectedLocationStart = SortedImportant{i,2};
        InspectedLocationEnd   = SortedImportant{i+2,2};
        
        InspectedWarning = SortedImportant{i,1};
        
        if InspectedLocationEnd - InspectedLocationStart < (40*fs)...
                    && WarningWorthAlert(InspectedWarning)
            if ~(CheckSimilarAlert(DisplayedAlerts,InspectedWarning,...
                    InspectedLocationStart,fs))
                % Save the last 3 Occurrences of the warning
                for z = 0:2
                    DisplayedAlerts{end+1,1} = InspectedWarning;
                    DisplayedAlerts{end,2} = SortedImportant{i+z,2};    
                end
               setappdata(0,'DisplayedAlerts',DisplayedAlerts);
            end
        end
    end
    
end
end