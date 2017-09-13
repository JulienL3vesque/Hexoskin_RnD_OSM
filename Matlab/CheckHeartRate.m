function [Warnings] = CheckHeartRate( Warnings, Buffer, Interval,fs, RealTime)

HeartRate = 0;
% Call this script to identify the warnings
WarningDefinition;

if RealTime
% Make sure Interval.RR is not empty
if ~isempty(Interval.RR)
    % If we have more than 6 seconds of data
    if (Interval.RRIndex(end) - Interval.RRIndex(1)) > 6*fs
        Temp = Interval.RRIndex(end);
        Temp = Interval.RRIndex <= Temp & ...
            Interval.RRIndex >= Temp - 6*fs;
        % Heart Rate = 60*fs/Distance
        HeartRate = mean(60*fs*(Interval.RR(Temp).^(-1)));
        
        SelectedRRIndex = Interval.RRIndex(Temp);

        % Checking for irregular Heart Rate 
        % If a difference of 25 is noticed then we have an irregular Heart
        % Beat
        
        Temp = ~((60*fs*(Interval.RR(Temp).^(-1)) < (HeartRate + 25))&...
            (60*fs*(Interval.RR(Temp).^(-1)) > (HeartRate - 25))); %&  ...
            %~(60*fs*(Interval.RR(Temp).^(-1)) > (1.7*HeartRate));

        IrregularRRIndex = SelectedRRIndex(Temp);

        % If more than 4 irregular heart beats are deteced in 6 sec then we
        % have an irregular heart rate
        if length(IrregularRRIndex) > 4
            WarningLocation = IrregularRRIndex(end);
            Warnings = Warning(IrregularRate,WarningLocation,Warnings,fs);
        end

        % Gets the current time in seconds
        CurrentTime = GetCurrentTime(Buffer);
        % Morning Time Starts at 5:30
        MorningTimeStart = 5*3600 + 30*60;
        % Morning Time Ends at 7:00
        MorningTimeEnd   = 7*3600; 
        if HeartRate > 80 &&  CurrentTime <=MorningTimeEnd && ...
                CurrentTime>= MorningTimeStart
            WarningLocation = SelectedRRIndex(end);
            Warnings = Warning(FastMorningRate,WarningLocation,Warnings,fs);
        end
    end
        
end
else
for i = 1:length(Interval.RR)
    
    if ~isempty(Interval.RR)
        % If we have more than 6 seconds of data
        if (Interval.RRIndex(i) - Interval.RRIndex(1)) > 6*fs
            Temp = Interval.RRIndex(i);
            Temp = Interval.RRIndex <= Temp & ...
                Interval.RRIndex >= Temp - 6*fs;
            % Heart Rate = 60*fs/Distance
            HeartRate = mean(60*fs*(Interval.RR(Temp).^(-1)));
        
            SelectedRRIndex = Interval.RRIndex(Temp);

            % Checking for irregular Heart Rate 
            % If a difference of 25 is noticed then we have an irregular Heart
            % Beat
        
            Temp = ~((60*fs*(Interval.RR(Temp).^(-1)) < (HeartRate + 25))&...
                (60*fs*(Interval.RR(Temp).^(-1)) > (HeartRate - 25))); %&  ...
                %~(60*fs*(Interval.RR(Temp).^(-1)) > (1.7*HeartRate));

            IrregularRRIndex = SelectedRRIndex(Temp);

            % If more than 4 irregular heart beats are deteced in 6 sec then we
            % have an irregular heart rate
            if length(IrregularRRIndex) > 4
                WarningLocation = IrregularRRIndex(end);
                Warnings = Warning(IrregularRate,WarningLocation,Warnings,fs);
            end

            % Gets the current time in seconds
            CurrentTime = GetCurrentTime(Buffer);
            % Morning Time Starts at 5:30
            MorningTimeStart = 5*3600 + 30*60;
            % Morning Time Ends at 7:00
            MorningTimeEnd   = 7*3600; 
            if HeartRate > 80 &&  CurrentTime <=MorningTimeEnd && ...
                    CurrentTime>= MorningTimeStart
                WarningLocation = SelectedRRIndex(i);
                Warnings = Warning(FastMorningRate,WarningLocation,Warnings,fs);
            end
        end
    end
end
end
end

