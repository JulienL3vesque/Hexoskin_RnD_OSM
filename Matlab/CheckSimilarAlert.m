function [ ExistSimilar ] = CheckSimilarAlert( AlertCell,WarningName,WarningLocation,fs )
% This function checks if an Alert appeared in the past 4 hours

Size = size(AlertCell);
Size = Size(:,1);
% This is used to stop the same occurences from being saved
ExistSimilar = 0;

for i = 1:Size

    % If we have the same Warning Type check if it occurs at a place close
    % to the old alert(4 hour range)
    if (strcmp(AlertCell{i,1},WarningName))
        if AlertCell{i,2} >= WarningLocation - 4*3600*fs && ...
                AlertCell{i,2} <= WarningLocation + 4*3600*fs
            ExistSimilar = 1;
            break;
        end
    end

end


