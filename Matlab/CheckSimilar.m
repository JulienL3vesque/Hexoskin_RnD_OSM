function [ ExistSimilar ] = CheckSimilar( WarningCell,WarningName,WarningLocation,fs )
% This function checks if a warning call has been found more than once

WarningDefinition;

Size = size(WarningCell);
Size = Size(:,1);
% This is used to stop the same occurences from being saved
ExistSimilar = 0;

for i = 1:Size

    % If we have the same Warning Type check if it occurs at a place close
    % to the old warning
    
    % If we are checking for IrregularRate check in 6*4 period= 24 sec
    if strcmp(WarningName,IrregularRate)
        if strcmp(WarningCell{i,1},WarningName)
            if WarningCell{i,2} >= WarningLocation - 24*fs && ...
                    WarningCell{i,2} <= WarningLocation + 24*fs
                ExistSimilar = 1;
                break;
            end
        end
    else
    % If we are checking for other warnings check in 6 sec period
        if strcmp(WarningCell{i,1},WarningName)
            if WarningCell{i,2} >= WarningLocation - 6*fs && ...
                    WarningCell{i,2} <= WarningLocation + 6*fs
                ExistSimilar = 1;
                break;
            end
        end
    end
end



