function [ WarningIDs ] = GetWarnings( Warnings, WarningType,...
    WarningLocation, WarningID, fs )
% This function returns the location of the 4 consecutive similar warnings
% that occur after and including WarningID

% Stores the location of the warning IDs 
WarningIDs = [];
CurrentID = 0;
if ~isempty(WarningID)

    LoopStart = 1;
    LoopEnd   = size(Warnings);
    % LoopEnd is a 1 by 2 matrix so we select one of the points
    LoopEnd   = LoopEnd(1);
   
    for j = LoopStart:LoopEnd

        if (strcmp(Warnings{j,1},WarningType))
            if WarningLocation == Warnings{j,2}
                CurrentID = j;
            end
            if length(WarningIDs) > 3 && CurrentID ~= 0
                break;
            % Save the warningIDs that are after the warning selected
            elseif CurrentID ~= 0 && Warnings{j,2} >= WarningLocation...
                    - 6*fs && Warnings{j,2} <= WarningLocation + 6*fs
                
                WarningIDs = [WarningIDs j];
            end
        end
    
    end
end

