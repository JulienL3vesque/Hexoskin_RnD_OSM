function [ImportantWarnings] = SelectImportantWarnings(...
    ImportantWarnings, Warnings, fs, RealTime)
% Check if the Warning occurs more then once
% If it occurs 4 consecutive times then it will be displayed 

WarningDefinition;

% Used to find how store where a warning occured
Location = [];

% Do the search on the last 4*WarningsNum warnings
AnalysisNum = 4*WarningNum;

% If not real time take all warnings
if RealTime
    if AnalysisNum >= size(Warnings)
        LoopStart = 1;
        LoopEnd   = size(Warnings);
        % LoopEnd is a 1 by 2 matrix so we select one of the points
        LoopEnd   = LoopEnd(1);
    else
        LoopStart = size(Warnings) - AnalysisNum;
        LoopEnd   = size(Warnings);
        LoopEnd   = LoopEnd(1);
    end

else
    LoopStart = 1;
    LoopEnd   = size(Warnings);
end

% Loop through all warning types
% If the warning type occurs more than 3 times in a certain period of time
% then save it
for j = 1:WarningNum
    
    Location = [];
    
    % Find how many times the warning occured and where it occured
    for k = LoopStart:LoopEnd
        if strcmp(WarningType(j),Warnings{k,1})
            Location = [Location k];
        end
    end
    
    % If the same warning happens more than 3 times then save it
    if length(Location) > 3
        for k = 1:length(Location)
            Exist =  CheckExist(ImportantWarnings,WarningType(j),...
                Warnings{Location(k),2});
            
            if ~Exist
                % If the warning occured in similar places only save one
                ExistSimilar = CheckSimilar(ImportantWarnings,...
                WarningType(j), Warnings{Location(k),2},fs);
                if ~ExistSimilar
                    % WarningIDs returns the consecutive Warnings that 
                    % occured
                    WarningIDs = GetWarnings( Warnings, WarningType(j),...
                        Warnings{Location(k),2}, Location(k), fs );
                    % If less than 4 warnings occured dont save
                    if length(WarningIDs)>3
                        ImportantWarnings{end+1,1} = WarningType(j);
                        ImportantWarnings{end,2}   = ....
                            Warnings{Location(k),2};
                    end
                end
            end
        end
    end
end

