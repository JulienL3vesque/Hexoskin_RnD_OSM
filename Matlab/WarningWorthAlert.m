function [ Worth ] = WarningWorthAlert( WarningName )
% This function specifies if the warning inspected is worth sending an
% alert or not
% Returns 1 if warning is important or 0 if warning is not important

WarningDefinition;

if strcmp(WarningName,IrregularRate)
    Worth = 0;
elseif strcmp(WarningName,AbnormalP)
    Worth = 0;
elseif strcmp(WarningName,AbnormalR)
    Worth = 0;
elseif strcmp(WarningName,AbnormalT)
    Worth = 0;
elseif strcmp(WarningName,LongP)
    Worth = 0;
elseif strcmp(WarningName,HighP)
    Worth = 0;
elseif strcmp(WarningName,HighT)
    Worth = 0;
elseif strcmp(WarningName,LongQRS)
    Worth = 0;
elseif strcmp(WarningName,ShortQRS)
    Worth = 0;
elseif strcmp(WarningName,ShortPR)
    Worth = 0;
elseif strcmp(WarningName,FastMorningRate)
    Worth = 0;
elseif strcmp(WarningName,SignificantQ)
    Worth = 0;
else
    Worth = 1;
end

