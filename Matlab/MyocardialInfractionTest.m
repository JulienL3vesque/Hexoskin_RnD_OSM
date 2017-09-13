function [Warnings] = MyocardialInfractionTest(Warnings, fs)
% This function checks for Myocardial Infaction

WarningDefinition;

Size = size(Warnings);
Size = Size(:,1);

% Saves the location of the STElevation
STLoc   = 0;
% Saves the location of the SignificantQ
% -2*fs*0.5 was selected since it is more than 0.5*fs
SigQLoc = -2*fs*0.5;
% Saves the location of the InvertedT
% -4*fs*0.5 was selected since it is more than 0.5*fs
InverT  = -4*fs*0.5;

for i = 1:Size
    % Loop until u find STElevation warning
    if strcmp(Warnings{i,1},STElevation)
        % Save location of warning
        STLoc = Warnings{i,2};
    end
    
    if strcmp(Warnings{i,1},SignificantQ)
        % Save location of warning
        SigQLoc = Warnings{i,2};
    end
    
    if strcmp(Warnings{i,1},InvertedT)
        % Save location of warning
        InverT = Warnings{i,2};
    end
    
    % If the all three warnings occured in sma place we have Myocardial
    % Infraction
    if SigQLoc > STLoc - 0.5*fs && SigQLoc < STLoc + 0.5*fs
        if InverT > STLoc - 0.5*fs && InverT < STLoc + 0.5*fs
            Warnings = Warning(MyocardialInfaction,STLoc,Warnings,fs);
        end
    end
end


%{

% Loop through the warnings
for i = 1:Size
    % Loop until u find STElevation warning
    if strcmp(Warnings{i,1},STElevation)
        % Save location of warning
        WarningLocation = Warnings{i,2};
        % Loop through the warnings again
        for j = 1:Size
           % Loop until u find SignificantQ warning
           if strcmp(Warnings{i,1},SignificantQ) 
               % When warning is found check if its close to STElevation
               % Warning
               if Warnings{j,2} < WarningLocation + 0.5*fs && ...
                       Warnings{j,2} > WarningLocation - 0.5*fs
                   % Loop through the warnings again
                   for k = 1:Size
                       % Loop until u find SignificantQ warning
                       if strcmp(Warnings{i,1},InvertedT) 
                            if Warnings{j,2} < WarningLocation ...
                                    + 0.5*fs && Warnings{j,2} >...
                                    WarningLocation - 0.5*fs
                                Warnings = Warning(MyocardialInfaction,...
                                    WarningLocation,Warnings);
                            end
                       end
                   end
               end
           end
        end
        
    end
end
%}
