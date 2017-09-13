function [ Ecg, RLocation, RQuality, NewEnd, Time, AllFile ] = ReadEcg( FileName, ...
    RQualityFile, EcgStart, EcgEnd, fs, AllFile)
% This function waits for data to be saved then reads it
% Inputs:
% FileName     : The name of the file containing ECG
% RFile        : The name of the file containing RR interval
% RQualityFile : The name of the file containing the quality of the R waves
% EcgStart     : The index to start reading
% EcgEnd       : The index to end reading
%
% Outputs:
% Ecg      : ECG signal that is being read between EcgStart and EcgEnd
% RLocation: Location of the R waves 
% RQuality : Quality of the R waves
%
% Additional comments:
% The time reading time is not constant. This is because we might end the
% reading during a PQRST signal. 
% So in case of the reading ending in a PQRST sigal we will wait for more
% data to be saved then we will add the new readings.
% 
% How it will be implemented:
% - Wait for 2 seconds of data 
% - Get the peaks in these 2 seconds
% - If the last peak ends in the last 0.47 seconds 
% - Wait for 0.47 seconds after the last peak
% - For exmaple: If last peak was at 1.8 seconds the data acquired will be
%   1.8+ 0.47 = 2.27 seconds
% 0.47 seconds is selected because its enough time for both the S and T
% waves to be detected

% Used to end the loop
Retry = true;

% Will be used incase we want to save more data
NewEnd = EcgEnd;

% Keep trying to read, while waiting for 0.1 sec, for the data to be stored
while Retry
    try
        
        % Reading First and Second column of the ECG file
        ReadRange = [EcgStart 1 EcgEnd 1];
        TimeRange = [EcgStart 0 EcgEnd 0];
        %Ecg = csvread(FileName, EcgStart, 1, ReadRange);************************************************************
        %Time = csvread(FileName,EcgStart,0, TimeRange);
        %% REMOVE AND UNCOMMENT TOP LINE
        if isempty(AllFile)
            AllFile = csvread(FileName);
        end
        AllEcg = AllFile(:,2);
        Ecg = AllEcg(EcgStart+1:EcgEnd+1);
        AllTime = AllFile(:,1);
        Time = AllTime(EcgStart+1:EcgEnd+1);
        %%
        
        % Change it to horizontal to be able to work with it later on
        Ecg = Ecg';
        
        % Read the first column containing the time an R wave occurs
        RWave = csvread(RQualityFile,1,0);
        RLocation = RWave(:,1);
        
        % Read the second column containing the quality of the R waves
        RQuality = RWave(:,2);
        
        % Change RLocation to position instead of time
        RLocation = round(RLocation*fs);

        % Keep the R waves that are between EcgStart and EcgEnd
        
        Temp = RLocation >= EcgStart & RLocation <= EcgEnd;
        RLocation = RLocation(Temp);
        RQuality  = RQuality(Temp);
        


        % Make sure RLocation is not empty to prevent errors
        if ~isempty(RLocation)
            
            % Find difference between peaks
            RR = diff(RLocation);

            % Find if any difference is much greater than mean
            % If much greater than mean then a peak might have been missed
            % So change the mean
            Temp = mean(RR)-30 < RR < mean(RR) + 30;
            RR = mean(RR(Temp));

            if ~isnan(RR)
                TWindowEnd   = round(RR*0.5);
                ToffWindow   = round(RR*0.14);
            else
                TWindowEnd   = round(350*fs/1000);
                ToffWindow   = round(100*fs/1000);
            end
            
            % If the last peak ended  TWindowEnd + ToffWindow before the 
            % end, we want to add more values
            while RLocation(end) > NewEnd - TWindowEnd - ToffWindow
                
                % Save old end
                EcgEnd = NewEnd;
                % Specify a new end 
                NewEnd = RLocation(end) + TWindowEnd + ToffWindow;
                % Set the new range
                TempRange = [(EcgEnd+1) 1 NewEnd 1];
                % Read the new samples 
                %TempEcg = csvread(FileName,(EcgEnd+1),1,TempRange);%*******************************************************
                
                %% REMOVE AND UNCOMMENT TOP LINE
                TempEcg = AllEcg(EcgEnd+2:NewEnd+1);
                %%
                
                
                % Read the first column containing the time an R wave 
                % occurs
                RWave = csvread(RQualityFile,1,0);
                RLocation = RWave(:,1);
        
                % Read the second column containing the quality of the R 
                % waves
                RQuality = RWave(:,2);
        
                % Change RLocation to position instead of time
                RLocation = (RLocation*fs);
        
                % Keep the R waves that are between EcgStart and EcgEnd
        
                Temp = RLocation >= EcgStart & RLocation <= NewEnd;
                RLocation = RLocation(Temp);
                RQuality  = RQuality(Temp);
        
                RLocation = round(RLocation);
                
                % Change to horizontal so they will be able to be added
                % together
                TempEcg = TempEcg';
                
                % Add the new read data to the old ECG
                Ecg = [Ecg TempEcg];
                
                % Find difference between peaks
                RR = diff(RLocation);

                % Find if any difference is much greater than mean
                % If much greater than mean then a peak might have been 
                % missed so change the mean
                Temp = mean(RR)-30 < RR < mean(RR) + 30;
                RR = mean(RR(Temp));

                if ~isnan(RR)
                    TWindowEnd   = round(RR*0.5);
                    ToffWindow   = round(RR*0.14);
                else
                    TWindowEnd   = round(350*fs/1000);
                    ToffWindow   = round(100*fs/1000);
                end
            
            end
        end
        
        % Signal is read no need to retry
        Retry = 0;
    catch
toc

        % If 10 seconds (100*0.1 = 10) have passed and the file does not 
        % contain enough information the device is probably not recording
        if Retry > 100
            % Save the results
            % Name of the file where the results will be saved
            EndFileName = 'RealStatus';
            Warnings = getappdata(0,'Warnings');
            ImportantWarnings = getappdata(0,'ImportantWarnings');
            DisplayedAlerts = getappdata(0,'DisplayedAlerts');
            Fail = getappdata(0,'Fail');
            PrintToExcel(Warnings,ImportantWarnings,DisplayedAlerts,...
                Fail,EndFileName);
            disp('Please check if the device is recording');
            Retry = 0;
        end
        
        Retry = Retry + 1;
        
        % Pause for 0.1 seconds and wait for more information to be stored
        pause(0.1);
    end
end
end

