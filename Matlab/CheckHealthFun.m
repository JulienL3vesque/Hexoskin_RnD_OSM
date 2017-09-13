function [ Warnings ] = CheckHealthFun(Warnings,Buffer,Interval,fs,RealTime...
    ,EcgStart,RIndex,Index,LongRQuality,NewEnd,Segment,Value,Ecg,Duration,IsAstro,Fail)


% Call this script to identify the warnings
WarningDefinition;

% Search for irregular heart rates
[Warnings] = CheckHeartRate(Warnings, Buffer, Interval, fs, RealTime);

%% Check if any wave has more than one peak

% Make sure the EcgStart includes the P wave that corresponds to the R wave
% before unselecting it

OldEcgStart = EcgStart;

if ~isempty(RIndex)
if EcgStart > RIndex(1) - ceil(200*fs/1000)
   EcgStart = RIndex(1) - ceil(200*fs/1000);
end
end

[P, Q, R, S, T, ~, PR, QT, ~, ~, QRS, AST, Iso] = UnselectBad...
    (Index, LongRQuality, EcgStart, NewEnd, fs, Buffer, Interval,...
    Segment, Value,RIndex);

EcgStart = OldEcgStart;

GoodP    = Index.P(P);
GoodQ    = Index.Q(Q);
GoodR    = Index.R(R);
GoodT    = Index.T(T);
GoodS    = Index.S(S);
[Peaks,Location] = findpeaks(Ecg);
Location = Location + EcgStart;


for i = 1:length(Peaks)
    
    for j = 1:length(GoodR)
     if j <= length(GoodP)    
     if Location(i) > GoodP(j) - 5 && Location(i) < GoodP(j) + 5 &&...
             Location(i) ~= GoodP(j)
        % Check if we have a plateau
        for k = 1:abs(Location(i)-GoodP(j))
            if Location(i) > GoodP(j)
                % If the difference between two consecutive points is
                % more than 0.005, then we dont have a plateau
                if abs(Buffer.Plot(GoodP(j)+k)-...
                        Buffer.Plot(GoodP(j)+k)) > 0.005
                    WarningLocation = GoodP(j);
                    Warnings = Warning(AbnormalP,WarningLocation,...
                        Warnings,fs);
                end
            else 
                if abs(Buffer.Plot(Location(i)+k)-...
                        Buffer.Plot(Location(i)+k)) > 0.005
                    WarningLocation = GoodP(j);
                    Warnings = Warning(AbnormalP,WarningLocation,...
                        Warnings,fs);
                end
            end          
        end
     end
     end    
        
     if Location(i) > GoodR(j) - 5 && Location(i) < GoodR(j) + 5
         if ~(Location(i) >= GoodR(j)-1 && Location(i) <= GoodR(j) + 1)
             WarningLocation = GoodR(j);
             Warnings = Warning(AbnormalR,WarningLocation,Warnings,fs);
         end
     end
        
     if j <= length(GoodT)        
     if Location(i) > GoodT(j) - 5 && Location(i) < GoodT(j) + 5 &&...
           Location(i) ~= GoodT(j)
        
       % Check if we have a plateau
       for k = 1:abs(Location(i)-GoodT(j))
           if Location(i) > GoodT(j)
               % If the difference between two consecutive points is
               % more than 0.005, then we dont have a plateau
               % If the difference between the the peak and detcted
               % point is more than 0.005 then T wave was not perfectly
               % detected so we wont consider a plateau
               if abs(Buffer.Plot(GoodT(j))-Buffer.Plot(GoodT(j)+k))...
                       > 0.005&&abs(Buffer.Plot(Location(i))-...
                       Buffer.Plot(GoodT(j))) < 0.005
                   WarningLocation = GoodT(j);
                   Warnings = Warning(AbnormalT,WarningLocation,...
                       Warnings,fs);
               end
           else 
               if abs(Buffer.Plot(Location(i))-Buffer.Plot...
                       (Location(i)+k)) > 0.005&&abs(Buffer.Plot...
                       (Location(i))-Buffer.Plot(GoodT(j))) < 0.005
                   WarningLocation = GoodT(j);
                   Warnings = Warning(AbnormalT,WarningLocation,...
                       Warnings,fs);
               end
           end
       end
    end
    end
    end
end


%% Check the Durations and Amplitudes
GoodDurationP = Duration.P(P);
GoodDurationT = Duration.T(T);
GoodIntervalPR = Interval.PR(PR);
GoodIntervalPRIndex = Interval.PRIndex(PR);
GoodSegmentQRS = Segment.QRS(QRS);
GoodIntervalQTc = Interval.QTc(QT);
GoodIndexQT = Interval.QTIndex(QT);
GoodIntervalQT = Interval.QT(QT);

% Length of AST might be 1 greater than Iso
if length(AST) ~= length(Iso)
    if isempty(Iso)
    GoodSTMeasurement = [];
    GoodSTMeasurementIndex = [];
    else
    GoodSTMeasurement = Value.STMeasurement(AST(1:end-1)&Iso);
    GoodSTMeasurementIndex = Value.STIndex(AST(1:end-1)&Iso);
    end
else
    GoodSTMeasurement = Value.STMeasurement(AST&Iso);
    GoodSTMeasurementIndex = Value.STIndex(AST&Iso);
end
% Reference Amplitude
RefAmp = abs(mean(Buffer.Plot(GoodR)));

% Start from the begining
[PTemp, QTemp, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~] = UnselectBad...
    (Index, LongRQuality, 1, NewEnd, fs, Buffer, Interval,...
    Segment, Value,RIndex);

% Using a few P waves from the begining as a reference
TempP = Index.P(PTemp);
% Using a few Q waves from the begining as a reference
TempQ = Index.Q(QTemp);

if length(TempP) >= 5
    RefP = abs(mean(Buffer.Plot(TempP(1:5))));
else
    RefP = abs(mean(Buffer.Plot(TempP(1:end))));
end
% If the reference P wave is low then we dont want to add this warning,
% since in certain cases it is normal for a person to have a low P
if RefP < 0.2*RefAmp
    RefP = nan;
end

if length(TempQ) >= 5
    RefQ = abs(mean(Buffer.Plot(TempQ(1:5))));
else
    RefQ = abs(mean(Buffer.Plot(TempQ(1:end))));
end

% If the reference Q wave is low then we dont want to add this warning,
% since in certain cases it is normal for a person to have a low Q
if RefQ < 0.1*RefAmp
    RefQ = nan;
end

if isnan(RefAmp)
    RefP = nan;
    RefQ = nan;
end

for i = 1:length(GoodR)
    
    if i <= length(GoodP)
        if GoodDurationP(i) > (110*fs/1000)
            WarningLocation = GoodP(i);
            Warnings = Warning(LongP,WarningLocation,Warnings,fs);
        end
        if Buffer.Plot(GoodP(i)) > RefAmp*0.25
            
            % In certain cases the signal is bad between two peaks so the P
            % wave is seen to be high but it is actually caused by a bad
            % noise.
            % In these cases we don't want to generate a warning
            
            % If there are more than 3 peaks with amplitude higher than 
            % 0.15 before the P wave then signal is noisy
            % 0.15 is chosen since it is a reasonable number for a 
            % noticeable peak
            
            % TempRange is a range before the P wave
            TempRange = GoodP(i) - 150:GoodP(i);
            
            if ~isempty(TempRange)
                % If the TempRange starts before a 1 then this is the first
                % P wave in the signal
                if TempRange(1) > 1
                    [Peaks,~] = findpeaks(Buffer.Plot(TempRange));
                else
                    % If this is the first P wave then we will generate a
                    % warning
                    Peaks = [];
                end
            else
                % If no peaks are detected then signal is smooth (No noise)
                Peaks = [];
            end
            
            % If Peaks is empty then we will generate a warning
            if isempty(Peaks)
                WarningLocation = GoodP(i);
                Warnings = Warning(HighP,WarningLocation,Warnings,fs);
            else
                % Get the peaks that are higher than 0.15 in amplitude
                
                Peaks = Peaks > 0.15;
                % If more than 3 peaks are found with amplitude higher than
                % 0.1 a warning won't be enerated
                if ~(sum(Peaks) > 3)
                    WarningLocation = GoodP(i);
                    Warnings = Warning(HighP,WarningLocation,Warnings,fs);
                end
            end
        % If we have a reference then check if P wave is relatively low,
        % else dont check and wait till we have a reference
        elseif ~isnan(RefP)
            % If P wave is relatively low then generate a warninig
            if Buffer.Plot(GoodP(i)) < RefP*0.6
                WarningLocation = GoodP(i);
                Warnings = Warning(LowP,WarningLocation,Warnings,fs);
            end 
            
        end
    end
    
    if i <= length(GoodSegmentQRS)
        if GoodSegmentQRS(i) > (120*fs/1000)
            %{
            if ~IsAstro
                WarningLocation = GoodR(i);
                Warnings = Warning(LongQRS,WarningLocation,Warnings,fs);
            else
                if GoodSegmentQRS(i) > (150*fs/1000)
                   WarningLocation = GoodR(i);
                   Warnings = Warning(LongQRS,WarningLocation,Warnings,fs);
                end
            end
            %}
        elseif GoodSegmentQRS(i) < (60*fs/1000)&&GoodSegmentQRS(i)~=0
            WarningLocation = GoodR(i);
            Warnings = Warning(ShortQRS,WarningLocation,Warnings,fs);
        end
    end
    
     if i <= length(GoodT)
        if Buffer.Plot(GoodT(i)) > 0.5*RefAmp
            WarningLocation = GoodT(i);
            Warnings = Warning(HighT,WarningLocation,Warnings,fs);
        elseif Buffer.Plot(GoodT(i)) < -0.15
            WarningLocation = GoodT(i);
            Warnings = Warning(InvertedT,WarningLocation,Warnings,fs);
        end
     end
    
     if i <= length(GoodIntervalPR)
         if GoodIntervalPR(i) > (200*fs/1000)
            WarningLocation = GoodIntervalPRIndex(i);
            Warnings = Warning(LongPR,WarningLocation,Warnings,fs);
         elseif GoodIntervalPR(i) < (120*fs/1000)&&GoodIntervalPR(i) ~= 0
             % If IsAstro dont use the PR segment length
             if ~IsAstro
                 %{
             if IsAstro    
                 if GoodIntervalPR(i) < (80*fs/1000)
                    WarningLocation = GoodIntervalPRIndex(i);
                    Warnings = Warning(ShortPR,WarningLocation,...
                        Warnings,fs);
                 end
             else
                 %}
                WarningLocation = GoodIntervalPRIndex(i);
                Warnings = Warning(ShortPR,WarningLocation,...
                    Warnings,fs);
             end
         end
     end
     
     if i<=length(GoodIntervalQTc)
         

          TWave = GoodT > GoodIndexQT(i) & GoodT < GoodIndexQT(i) + ...
              GoodIntervalQT(i);

          TWave = GoodT(TWave);
         
         if GoodIntervalQTc(i) > (460*fs/1000)
             % If the data we have is from the AstroSkin make the detection
             % interval of LongQTcInterval larger to accommodate more error 
            if IsAstro 
               % If the T wave has low amplitude dont save a warning since
               % the T wave is not so reliable
               if Buffer.Plot(TWave) > 0.1 
                  if GoodIntervalQTc(i) > (500*fs/1000)
                  WarningLocation = TWave;
                  Warnings = Warning(LongQTc,WarningLocation,Warnings,fs);
                  end
               end
            else
               WarningLocation = GoodIndexQT(i);
               Warnings = Warning(LongQTc,WarningLocation,Warnings,fs);
            end
            
         elseif GoodIntervalQTc(i) < (350*fs/1000)&&GoodIntervalQTc(i) ~= 0
            % If the data we have is from the AstroSkin make the detection
            % interval of LongQTcInterval larger to accommodate more error 
            if IsAstro 
               if GoodIntervalQTc(i) < (300*fs/1000)
                  WarningLocation = TWave;
                  Warnings = Warning(ShortQTc,WarningLocation,Warnings,fs);
               end
            else
                WarningLocation = TWave;
                Warnings = Warning(ShortQTc,WarningLocation,Warnings,fs);
            end
         end
     end
    
     if i<=length(GoodSTMeasurement)
         if IsAstro
         if GoodSTMeasurement(i) > 0.13
            WarningLocation = GoodSTMeasurementIndex(i);
            Warnings = Warning(STElevation,WarningLocation,Warnings,fs);
         elseif GoodSTMeasurement(i) < -0.1
            %WarningLocation = GoodSTMeasurementIndex(i);
            %Warnings = Warning(STDepression,WarningLocation,Warnings,fs);
         end
         else
         if GoodSTMeasurement(i) > 0.1
            WarningLocation = GoodSTMeasurementIndex(i);
            Warnings = Warning(STElevation,WarningLocation,Warnings,fs);
         elseif GoodSTMeasurement(i) < -0.05
            WarningLocation = GoodSTMeasurementIndex(i);
            Warnings = Warning(STDepression,WarningLocation,Warnings,fs);
         end
         end
     end
     
     % Loc specifies the location of the R Index we are currently working
     % with
     Loc =  Index.R == GoodR(1);
     Loc = find(Loc);
     Loc = Loc(1);
     
     % Generate warning when Q is missed
     if Fail.Q(Loc + i - 1) == 0
         WarningLocation = GoodR(i);
         Warnings = Warning(MissedQ,WarningLocation,Warnings,fs);
     end
     
     % Generate warning when P is missed
     if Fail.P(Loc + i - 1) == 0
         WarningLocation = GoodR(i);
         Warnings = Warning(MissedP,WarningLocation,Warnings,fs);
     end
     
     if i <= length(GoodQ)
         % If the Q is lower than 1/3 the QRS complex then it is abnormal
         % The R and Q might not match in certain cases but that is okay
         % since another close R wave will be used
        if Buffer.Plot(GoodQ(i)) < -(Buffer.Plot(GoodR(i)) - ...
                Buffer.Plot(GoodQ(i)))/3
            WarningLocation = GoodQ(i);
            Warnings = Warning(SignificantQ,WarningLocation,Warnings,fs);
        end
        
        if ~isnan(RefQ)
           if abs(Buffer.Plot(GoodQ(i))) < abs(RefQ *0.5)
            WarningLocation = GoodQ(i);
            Warnings = Warning(LowQ,WarningLocation,Warnings,fs);
           end
        end
     end
     
     if i <= length(GoodS)
        % If the S is lower than -1.8mV then S wave is lower than normal 
        if Buffer.Plot(GoodS(i)) < -RefAmp*0.7
            WarningLocation = GoodS(i);
            Warnings = Warning(SignificantS,WarningLocation,Warnings,fs);
        end
     end
     
     
     Warnings = MyocardialInfractionTest(Warnings, fs);
end
end

