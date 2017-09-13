function [ Warnings ] = Warning( WarningName,WarningLocation,Warnings,fs)
% This function stores all the warnings and the locations they occured

Exist = CheckExist(Warnings,WarningName,WarningLocation,fs);
% If is does not exist then we add it to the list
if ~(Exist)
    Warnings{end+1,1} = WarningName;
    Warnings{end,2} = WarningLocation;
end
end

