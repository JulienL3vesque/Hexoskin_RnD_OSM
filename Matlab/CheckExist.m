function [ Exist ] = CheckExist(WarningCell,WarningName,WarningLocation,fs)
% This function checks if a warning cell contains a certain warning

WarningDefinition;

Size = size(WarningCell);
Size = Size(:,1);
% This is used to stop the same occurences from being saved
Exist = 0;

for i = 1:Size

    % If we are checking for Irregular Heart Rate then check in a 6 sec
    % range
    if strcmp(WarningName,IrregularRate)
        if strcmp(WarningCell{i,1},WarningName)
            if WarningCell{i,2} >= WarningLocation - 6*fs && ...
                    WarningCell{i,2} <= WarningLocation + 6*fs
                Exist = 1;
                break;
            end
        end
    
    else
        % If the a warning has same name and location as a previous warning 
        % dont save it
        if strcmp(WarningCell{i,1},WarningName) && ...
                (WarningCell{i,2} == WarningLocation)
            Exist = 1;
            break;
        end
    end

end

