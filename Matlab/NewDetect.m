function [ Index, Fail, Buffer ] = NewDetect( fs, ...
    Index, Fail, Buffer, RIndex, IsAstro, RealTime )
% This function detected the PQRST waves given the R wave location
%   Detailed explanation goes here

% Averging window size
% Find difference between peaks
RR = diff(RIndex);

% Find if any difference is much greater than mean
% If much greater than mean then a peak might have been missed
% So change the mean
Temp = mean(RR)-30 < RR < mean(RR) + 30;
RR = mean(RR(Temp));

if ~isnan(RR)&&RealTime
    QWindow      = round(RR*0.12);
    QonWindow    = round(RR*0.03);
    PWindowStart = round(RR*0.25);
    PWindowEnd   = round(RR*0.1);
    PonWindow    = round(RR*0.08);
    PoffWindow   = round(RR*0.08);
    SWindow      = round(RR*0.12);
    SoffWindow   = round(RR*0.03);
    TWindowStart = round(RR*0.2);
    TWindowEnd   = round(RR*0.5);
    TonWindow    = round(RR*0.14);
    ToffWindow   = round(RR*0.14);
else
    QWindow      = round(80*fs/1000);
    QonWindow    = round(20*fs/1000);
    PWindowStart = round(200*fs/1000);
    PWindowEnd   = round(40*fs/1000);
    PonWindow    = round(60*fs/1000);
    PoffWindow   = round(60*fs/1000);
    SWindow      = round(80*fs/1000);
    SoffWindow   = round(20*fs/1000);
    TWindowStart = round(150*fs/1000);
    TWindowEnd   = round(350*fs/1000);
    TonWindow    = round(100*fs/1000);
    ToffWindow   = round(100*fs/1000);
end
 

for i = 1:length(RIndex)

%% Q wave detection
% Check for a minimum in a QWindow time frame
% The minimum value found in this time frame is the Q wave

% Make sure it is vertical
Buffer.Plot = Buffer.Plot(:);
QCheck = RIndex(i) - QWindow;

if QCheck <= 0
    QAdjust = abs(QCheck)+1;
else
    QAdjust = 0;
end

% Find the negative peaks
[Peaks, Location] = findpeaks(-Buffer.Plot((RIndex(i)-QWindow+QAdjust)...
    :(RIndex(i)-3)));

% Take the first negative peak as the Q wave.
Mean = abs(mean(Peaks));

% Select the closest significant negative peak
for j = length(Peaks):-1:1
    if abs(Peaks(j)) >= 0.7*Mean
        QTempIndex = Location(j) + RIndex(i)- QWindow + QAdjust - 1;
        break;
    end
end

% If no inverse peak was detected
if ~exist('QTempIndex','var')|| isempty(Peaks)
    [~, Counter] = min(Buffer.Plot((RIndex(i)- QWindow+QAdjust)...
        :(RIndex(i))));

    % Location of the detected Q wave
    QTempIndex = Counter + RIndex(i)-QWindow + QAdjust - 1;
end
% Switch to horizontal
Buffer.Plot = [Buffer.Plot]';

% If QTempIndex < 2 then the signal just started
% We will not use this reading
if(QTempIndex < 2)
% disp('Signal just started, Q wave cannot be detected');

% 0 indicates an unsuccessful reading
QFailBin = 0;
Fail.Q = [Fail.Q QFailBin];
QTempIndex = [];

% Making sure that the Q wave is the ONLY minimum 
% If we have more than one minimum then Q wave is not found
elseif Buffer.Plot(QTempIndex - 1) > Buffer.Plot(QTempIndex)
    Index.Q = [Index.Q QTempIndex];
    
    % 1 indicates a successful reading
    QFailBin = 1;
    Fail.Q = [Fail.Q QFailBin];
    
% We have a common minimum so the Q wave is missing    
else
    % Reset the Index because it's not a good index
    QTempIndex = [];
    
    % 0 indicates an unsuccessful reading
    QFailBin = 0; 
    Fail.Q = [Fail.Q QFailBin];
    
    display('Missed Q wave detection')
end

%% Detect the begining of the Q wave

% If a Q wave was detected
if ~isempty(QTempIndex)
    
    % If the signal started less than QonWindow ago
    if (QTempIndex-QonWindow) < 1
        % Find the maximum from the begining of the ECG till the Q wave
        [~, Counter] = max(Buffer.Plot(1:QTempIndex));
    else
        % Find the maximum in a 30ms window before the Q wave
        [~, Counter] = max(Buffer.Plot((QTempIndex-QonWindow)...
            :QTempIndex));
    end
    
    % The location of the begining of the Q wave
    QonTempIndex = (QTempIndex-QonWindow) + Counter - 1;
    
    % Boolean used for the detection
    QonTest  = 1;
    QonCount = 1;

    % Loop through 20 ms before the Q index and when a change in the
    % slope's sign occurs we found the location of Qon (begining of Q wave)
    while QonTest == 1
        
        % If we have no slope change happened and it reached the Q wave
        % then stop the loop
        if (QonTempIndex - QonCount -1) < 1 
            break;
        end
        
        % Multiply two derivative values to check for a sign change
        QDerCheck = Buffer.PlotD1(QonTempIndex-1-QonCount)*Buffer.PlotD1(QonTempIndex-QonCount);
        QDer2Check = Buffer.PlotD2(QonTempIndex-1-QonCount)*Buffer.PlotD2(QonTempIndex-QonCount);
        
        QDerDiff = Buffer.PlotD1(QonTempIndex-1-QonCount) - Buffer.PlotD1(QonTempIndex-QonCount);
     
        
        if QDerDiff > 0
            QonTest = 0;
            
        % If QDerCheck is negative this indicates a change in the 
        % slope's sign
        % If QDerCheck is <= 0.01 we assume its equivalent to zero
        elseif QDerCheck <= 0.01 
            QonTest = 0;
            
        % If we checked 4 smaples and we still didn't find Qon then use the
        % second derivative by checking when its negative
        elseif QonCount > 4 && QDer2Check < 0                                    
            QonTest = 0;
        
        % If no sign change occured keep checking
        else
            QonCount = QonCount +1;
        end
    end
    
    % Update the Qon Index
    QonTempIndex = QonTempIndex - QonCount;
    % Save the Index
    Index.Qon = [Index.Qon QonTempIndex];
end

%% P wave detection
% Search a window starting from PWindowStart to the left of R wave
% and ending PWindowEnd to the left of R wave
% The maximum value in this interval is considered the P wave

% Indicate the location to begin the search
PStart = RIndex(i) - PWindowStart;
% Indicate the location to end the search
PEnd   = RIndex(i) - PWindowEnd;

% If PStart < 1 then the recording started during or after a P wave
if PStart <= 1
    % Start at 2 not 1 to prevent negative indexing
    PStart = 2;
end

% If PEnd is < 0 then the recording started after a P wave
if PEnd <= 0
    % Indicate P wave is not present in ECG
    PTempIndex = [];
    disp('Signal just started P wave cannot be detected');
    
else
    % Make it vertical
    Buffer.Plot = Buffer.Plot(:);
    % Find maximum
    [Amp, Counter] = max(Buffer.Plot(PStart:PEnd));
    % Return it to horizontal
    Buffer.Plot = Buffer.Plot';
    
% Check for an inverted P wave
[InvertedAmp, InvertedCounter] = min(Buffer.Plot(PStart:PEnd));

% If the T wave amplitude detected is low
if Amp <= 0.07
    % A low value to be used as a reference for inverted P waves
    Amp = 0.07;

    % If the minimum is equal to 3 times the max value(in case of inversion 
    % max value should be close to zero)
    if InvertedAmp < -3*Amp
        Counter = InvertedCounter;
        Inverted = 1;
        % The temporary P wave index
        PTempIndex = PStart + Counter - 1;
    else
        Inverted = 0;
        % If it is not inverted find the peaks in the range and take the 
        % first significant peak
        [Amp,Loc] = findpeaks(Buffer.Plot(PStart:PEnd));
        % Find the max to determine the significant peak
        AmpMax = abs(max(Amp));

        % Loop through the peaks and take the first significant peak
        for j = 1:length(Loc)
           % If the Peak is more than 0.7* Max then it is significant
           if abs(Amp(j)) >=  0.7*AmpMax
               % Save the significant peak
               PTempIndex = Loc(j) + PStart - 1;
               % Peak was found stop looking
               break;
           end
        end
    end

else
    Inverted = 0;
    % If it is not inverted find the peaks in the range and take the first
    % significant peak
    [Amp,Loc] = findpeaks(Buffer.Plot(PStart:PEnd));
    % Find the max to determine the significant peak
    AmpMax = abs(max(Amp));
    
    % Loop through the peaks and take the closest significant peak
    for j = length(Loc):-1:1
       % If the Peak is more than 0.7* Max then it is significant
       if Amp(j) >=  0.7*AmpMax
           % Save the significant peak
           PTempIndex = Loc(j) + PStart - 1;
           % Peak was found stop looking
           break;
       end
    end
end
    
    %{
    PTempIndex = PStart + Counter -1;

    % Check if the temporary P wave is a true P wave
    % Make sure it's the only maximum
    % Make sure the first derivative is between -8 and 8 
    % These numbers were found by testing
    if Buffer.Plot(PTempIndex - 1) < Buffer.Plot(PTempIndex) ...
        && abs(Buffer.PlotD1(PTempIndex)) < 8
    
    % There could be P waves that have plateaued so apply second derivative
    % condition to a range around the maximum
    PD2 = Buffer.PlotD2(PTempIndex - 3: PTempIndex + 3);
    
    % Check if any second derivative is < -50
    PD2Check = PD2 < -50;
    
    % If any second derivative is less than -50 then the Temp P wave is
    % valid
        if any(PD2Check)
        Index.P = [Index.P PTempIndex];
    
        % Indicate successful detection
        PFailBin = 1;
        Fail.P = [Fail.P PFailBin];
        else
            % The P wave we had isn't valid
            PTempIndex = [];
        end
    else
        % The P wave we had isn't valid
        PTempIndex = [];
    end

end
%}

% Change it to horizontal
Buffer.Plot = Buffer.Plot';
% In case no peaks were found execute this step
% This step should not occur but it is there for safety
if ~exist('PTempIndex','var')
   PTempIndex = PStart + Counter - 1;
elseif ~Inverted
    if isempty(Loc)
        PTempIndex = PStart + Counter - 1;
    end
end

% Check if the slope changes sign at P wave or before that or after that
if (Buffer.PlotD1(PTempIndex - 1)*Buffer.PlotD1(PTempIndex)) < 0 ||...
   (Buffer.PlotD1(PTempIndex - 2)*Buffer.PlotD1(PTempIndex - 1)) < 0 || ...
   ((Buffer.PlotD1(PTempIndex )*Buffer.PlotD1(PTempIndex + 1)) < 0)
    
    % Save the index
    Index.P = [Index.P PTempIndex];
    
    % Indicate successful detection
    PFailBin = 1;
    % Save the result
    Fail.P = [Fail.P PFailBin];
        
else
    % Empty the temporary index bcz it is not valid
    PTempIndex = [];
    
    % Indicate unsuccessful detection
    PFailBin = 0;
    % Save the result
    Fail.P = [Fail.P PFailBin];
    
    disp('Missed P wave detection');
end














% If a P wave was detected look for when it started (Pon) and when it
% ended (Poff)
if ~isempty(PTempIndex)

    PonCount = 1;
    PonTest = 1;
    PonTempIndex = PTempIndex - 1;
    
    while PonTest == 1
        
        if (PonTempIndex + PonCount - 1) < 2
            break;
        elseif (PonTempIndex - PonCount - 1) <  PTempIndex - PonWindow
            break;
        end
     
       % Calculate the difference between two consecutive derivatives
       PDerDiff   = Buffer.PlotD1(PonTempIndex + PonCount) - ...
           Buffer.PlotD1(PonTempIndex + PonCount - 1);
        
       % If the difference is more than 0 then the slope stoppped
       % increasing.
       % This indicates the beginning of the P wave
       if Inverted
            if PDerDiff < 0
                PonTest = 0;
            else
                PonCount = PonCount +1;
            end
       else
            if PDerDiff > 0
                PonTest = 0;
            else
                PonCount = PonCount +1;
            end
       end
    end

    % Find Pon Index
    PonTempIndex = PTempIndex - PonCount ;
    % Save the Index
    Index.Pon = [Index.Pon PonTempIndex];
    
    % Search in a window after P wave for Poff

    if PTempIndex + PoffWindow > length(Buffer.Plot)
        PoffWindow = length(Buffer.Plot) - PTempIndex;
    end
    
    if Inverted
        [~, Counter] = max(Buffer.Plot(PTempIndex:...
            PTempIndex + PoffWindow ));
    else
        [~, Counter] = min(Buffer.Plot(PTempIndex:...
            PTempIndex + PoffWindow ));
    end
    % Find the Toff Index
    PoffTempIndex = PTempIndex + Counter - 1; 
    
    PoffMaxIndex = PoffTempIndex;

    PoffTempIndex = PTempIndex;
    
    PoffTest = 1;
    PoffCount = 1;
    
    % Loop through PoffWindow after the P index and when the slope changes 
    % we found the location of Poff (end of P wave)
    while PoffTest == 1
        
        % If we have no slope change happened and it reached the  P wave
        % then stop the loop

        if (PoffMaxIndex  - PoffTempIndex - PoffCount - 1) < 1 
            break;
        end

        PDerDiff = Buffer.PlotD1(PoffTempIndex + PoffCount) - ...
            Buffer.PlotD1(PoffTempIndex + PoffCount + 1);
        
        if Inverted
            if PDerDiff > 1
                PoffTest = 0;
            else
                PoffCount = PoffCount  + 1;
            end
        else
            if PDerDiff < -1
                PoffTest = 0;
            else
                PoffCount = PoffCount  + 1;
            end
        end
    end
    
    % Update the Poff Index
    PoffTempIndex = PoffTempIndex + PoffCount + 1;

    % Save the Index
    Index.Poff = [Index.Poff PoffTempIndex];
end



























%{
% If PTempIndex is empty then we failed to detect a P wave
if isempty(PTempIndex)
    % Indicate unsuccessful detection
    PFailBin = 0;
    Fail.P = [Fail.P PFailBin];
    disp('Failed P wave detection');
        
% If the P wave was detected search for the begining of the P wave: Pon
else
    % Make sure we have more than PonWindow before the detection of the 
    % P wave. Because Pon will not be in the signal
    if PTempIndex >= PonWindow
        [~, Counter] = min(Buffer.Plot(PTempIndex)-round(fs*60/1000)...
            :PTempIndex);
            
        PonTempIndex = PTempIndex - PonWindow + Counter -1;

        PonTest = 1;
        PonCount = 1;
    
        % Loop through PonWindow before the P index and when the slope  
        % changes we found the location of Pon (beginning of P wave)
        while PonTest == 1
        
            % If we have no slope change happened and it reached the  P 
            % wave then stop the loop
            if (PonTempIndex  + PonCount + 1 - PTempIndex) > 1 
                break;
            end
        
            PDerDiff = Buffer.PlotD1(PonTempIndex + PonCount) - ...
                Buffer.PlotD1(PonTempIndex + PonCount + 1);
     
            if PDerDiff < 0
                PonTest = 0;
            else
                PonCount = PonCount  + 1;
            end
        end
    
        % Update the Pon Index
        PonTempIndex = PonTempIndex + PonCount;
        
        % The start of the P wave
        Index.Pon = [Index.Pon PonTempIndex];
    end
        
    % Search for the end of the P wave: Poff
    % The range of the search is from P to 60ms after P 
        
    [~, Counter] = min(Buffer.Plot(PTempIndex:...
           PoffWindow + PTempIndex));
    PoffMaxIndex = PTempIndex + Counter -1;

    PoffTempIndex = PTempIndex;
    
    PoffTest = 1;
    PoffCount = 1;
    
    % Loop through PoffWindow after the P index and when the slope changes 
    % we found the location of Poff (end of P wave)
    while PoffTest == 1
        
        % If we have no slope change happened and it reached the  P wave
        % then stop the loop
        if (PoffMaxIndex  - PoffTempIndex - 1) < 1 
            break;
        end
        
        PDerDiff = Buffer.PlotD1(PoffTempIndex + PoffCount) - ...
            Buffer.PlotD1(PoffTempIndex + PoffCount + 1);
     
        if PDerDiff < 0
            PoffTest = 0;
        else
            PoffCount = PoffCount  + 1;
        end
    end
    
    % Update the Poff Index
    PoffTempIndex = PoffTempIndex + PoffCount;

    % The start of the P wave
    Index.Poff = [Index.Poff PoffTempIndex];
        
end
%}
%% S wave detection

% Check for a minimum in an SWindow time frame
% The minimum value found in this time frame is the S wave

% Make sure it is vertical
Buffer.Plot = Buffer.Plot(:);

SCheck = RIndex(i) + SWindow;

[~, Counter] = min(Buffer.Plot((RIndex(i)) : SCheck));

% Location of the detected S wave
STempIndex = Counter + RIndex(i)  - 1;

% Switch to horizontal
Buffer.Plot = [Buffer.Plot]';

% Making sure that the S wave is the ONLY minimum 
% If we have more than one minimum then S wave is not found
if Buffer.Plot(STempIndex + 1) > Buffer.Plot(STempIndex)
    Index.S = [Index.S STempIndex];
    
    % 1 indicates a successful reading
    SFailBin = 1;
    Fail.S = [Fail.S SFailBin];
    
% We have a common minimum so the S wave is missing    
else
    % Reset the Index because it's not a good index
    STempIndex = [];
    
    % 0 indicates an unsuccessful reading
    SFailBin = 0; 
    Fail.S = [Fail.S SFailBin];
    
    display('Missed S wave detection')
end


%% Detect the end of the S wave

% If an S wave was detected
if ~isempty(STempIndex)
    

    % Find the maximum in an SoffWindow window after the S wave
    [~, Counter] = max(Buffer.Plot((STempIndex)...
        :STempIndex + SoffWindow));

    
    % The location of the begining of the S wave
    SoffTempIndex = STempIndex + Counter - 1;
    
    % Boolean used for the detection
    SoffTest  = 1;
    % Used to determine the new Soff
    SoffCount = 1;

    % Loop through SoffWindow after the S index and when a change in the
    % slope's sign occurs we found the location of Soff (end of S wave)
    while SoffTest == 1
        
        % If no slope change happened and it reached the end
        % of the ECG then stop the loop
        if (SoffTempIndex + SoffCount + 1) > length(Buffer.Plot) 
            break;
        end
        
        % Multiply two derivative values to check for a sign change
        SDerCheck  = Buffer.PlotD1(SoffTempIndex+1+SoffCount)*...
            Buffer.PlotD1(SoffTempIndex+SoffCount);
        SDer2Check = Buffer.PlotD2(SoffTempIndex+1+SoffCount)*...
            Buffer.PlotD2(SoffTempIndex+SoffCount);
     
        % Calculate the difference between two consecutive derivatives
        SDerDiff   = Buffer.PlotD1(SoffTempIndex+SoffCount) - ...
            Buffer.PlotD1(SoffTempIndex+SoffCount + 1);
        
        % If the difference is more than 0 then the slope stopped
        % increasing
        % This indicates the end of the S wave
        if SDerDiff > 0
            SoffTest = 0;

        % If SDerCheck is negative this indicates a change in the 
        % slope's sign
        % If SDerCheck is <= 0.01 we assume its equivalent to zero
        elseif SDerCheck <= 0.01 
            SoffTest = 0;
            
        % If we checked 4 smaples and we still didn't find Qon then use the
        % second derivative by checking when its negative
        elseif SoffCount > 4 && SDer2Check < 0                                    
            SoffTest = 0;
        
        % If no sign change occured keep checking
        else
            SoffCount = SoffCount +1;
        end
    end
    
    % Update the Soff Index
    SoffTempIndex = SoffTempIndex + SoffCount;
    % Save the Index
    Index.Soff = [Index.Soff SoffTempIndex];
end


%% Detect T wave

% Set the begining and ending time for the search
% Begin TWindowStart after R wave
% End TWindowEnd after R wave

%RDiff = diff(RIndex);
TStart = RIndex(i) + TWindowStart;
TEnd   = RIndex(i) + TWindowEnd;

% This is added for safety
if TEnd > length(Buffer.Plot)
    TEnd = length(Buffer.Plot);
end

%{
if ~isempty(RDiff)
    % If we have a fast heart rate start the search for T earlier and end
    % earlier
    if 60*fs*(mean(RDiff).^(-1)) > 120
        TStart = RIndex(i) + round(fs*100/1000);
        TEnd   = TStart    + round(fs*150/1000);
    end
end
%}

% Make sure it is vertical
Buffer.Plot = Buffer.Plot(:);
% Calculate the Maximum to be used for finding P wave
[Amp, Counter] = max(Buffer.Plot(TStart:TEnd));

% Check for an inverted T wave

[InvertedAmp, InvertedCounter] = min(Buffer.Plot(TStart:TEnd));

% If the T wave amplitude detected is low
if Amp <= 0.1
    % A low value to be used as a reference for inverted T waves
    Amp = 0.1;

    % If the minimum is equal to 3 times the max value(in case of inversion 
    % max value should be close to zero)
    if InvertedAmp < -3*Amp
        Counter = InvertedCounter;
        Inverted = 1;
        % The temporary T wave index
        TTempIndex = TStart + Counter - 1;
    else
        Inverted = 0;
        % If it is not inverted find the peaks in the range and take the 
        % first significant peak
        [Amp,Loc] = findpeaks(Buffer.Plot(TStart:TEnd));
        % Find the max to determine the significant peak
        AmpMax = abs(max(Amp));

        % Loop through the peaks and take the first significant peak
        for j = 1:length(Loc)
           % If the Peak is more than 0.7* Max then it is significant
           if abs(Amp(j)) >=  0.7*AmpMax
               % Save the significant peak
               TTempIndex = Loc(j) + TStart - 1;
               % Peak was found stop looking
               break;
           end
        end
    end

else
    Inverted = 0;
    % If it is not inverted find the peaks in the range and take the first
    % significant peak
    [Amp,Loc] = findpeaks(Buffer.Plot(TStart:TEnd));
    % Find the max to determine the significant peak
    AmpMax = abs(max(Amp));
    
    % Loop through the peaks and take the first significant peak
    for j = 1:length(Loc)
       % If the Peak is more than 0.7* Max then it is significant
       if abs(Amp(j)) >=  0.7*AmpMax
           % Save the significant peak
           TTempIndex = Loc(j) + TStart - 1;
           % Peak was found stop looking
           break;
       end
    end
end

% Change it to horizontal
Buffer.Plot = Buffer.Plot';
% In case no peaks were found execute this step
% This step should not occur but it is there for safety
if ~exist('TTempIndex','var')
   TTempIndex = TStart + Counter - 1;
elseif ~Inverted
    if isempty(Loc)
        TTempIndex = TStart + Counter - 1;
    end
end

% Check if the slope changes sign at T wave or before that or after that
if (Buffer.PlotD1(TTempIndex - 1)*Buffer.PlotD1(TTempIndex)) < 0 ||...
   (Buffer.PlotD1(TTempIndex - 2)*Buffer.PlotD1(TTempIndex - 1)) < 0 || ...
   ((Buffer.PlotD1(TTempIndex )*Buffer.PlotD1(TTempIndex + 1)) < 0)
    
    % Save the index
    Index.T = [Index.T TTempIndex];
    
    % Indicate successful detection
    TFailBin = 1;
    % Save the result
    Fail.T = [Fail.T TFailBin];
        
else
    % Empty the temporary index bcz it is not valid
    TTempIndex = [];
    
    % Indicate unsuccessful detection
    TFailBin = 0;
    % Save the result
    Fail.T = [Fail.T TFailBin];
    
    disp('Missed T wave detection');
end

% If a T wave was detected look for when it started (Ton) and when it
% ended (Toff)
if ~isempty(TTempIndex)
    %{
    % Search in a window of TonWindow before T wave for Ton
    Range = TTempIndex - TonWindow:TTempIndex;
    Temp  = Buffer.Plot(Range) == 0;
    
    Counter = Range(Temp);
    %}
    TonCount = 1;
    TonTest = 1;
    TonTempIndex = TTempIndex - 1;
    
    while TonTest == 1
        
        if ~isempty(Index.S)&& Fail.S(end)
           % If no slope change happened and it reached the
           % S wave then stop the loop
           if (TonTempIndex - TonCount) < Index.S(end)
               break;
           end
        elseif (TonTempIndex - TonCount - 1) <  TTempIndex - TonWindow
            break;
        end
     
       % Calculate the difference between two consecutive derivatives
       TDerDiff   = Buffer.PlotD1(TonTempIndex+TonCount) - ...
           Buffer.PlotD1(TonTempIndex+TonCount - 1);
        
       % If the difference is more than 0 then the slope stoppped
       % increasing.
       % This indicates the beginning of the T wave
       if Inverted
            if TDerDiff < 0
                TonTest = 0;
            else
                TonCount = TonCount +1;
            end
       else
            if TDerDiff > 0
                TonTest = 0;
            else
                TonCount = TonCount +1;
            end
       end
    end
    %{
    if ~isempty(Counter)
        Counter = Counter(end);
    else
    [~, Counter] = min(Buffer.Plot(TTempIndex - round(100*fs/1000)...
        :TTempIndex));
    end
    %}
    % Find Ton Index
    TonTempIndex = TTempIndex - TonCount ;
    % Save the Index
    Index.Ton = [Index.Ton TonTempIndex];
    
    % Search in a window after T wave for Toff

    if TTempIndex + ToffWindow > length(Buffer.Plot)
        ToffWindow = length(Buffer.Plot) - TTempIndex;
    end
    
    if Inverted
        [~, Counter] = max(Buffer.Plot(TTempIndex:...
            TTempIndex + ToffWindow ));
    else
        [~, Counter] = min(Buffer.Plot(TTempIndex:...
            TTempIndex + ToffWindow ));
    end
    % Find the Toff Index
    ToffTempIndex = TTempIndex + Counter - 1; 
    
    ToffMaxIndex = ToffTempIndex;

    ToffTempIndex = TTempIndex;
    
    ToffTest = 1;
    ToffCount = 1;
    
    % Loop through ToffWindow after the T index and when the slope changes 
    % we found the location of Toff (end of T wave)
    while ToffTest == 1
        
        % If we have no slope change happened and it reached the  T wave
        % then stop the loop

        if (ToffMaxIndex  - ToffTempIndex -ToffCount - 1) < 1 
            break;
        end

        TDerDiff = Buffer.PlotD1(ToffTempIndex + ToffCount) - ...
            Buffer.PlotD1(ToffTempIndex + ToffCount + 1);
        
        if Inverted
            if TDerDiff > 1
                ToffTest = 0;
            else
                ToffCount = ToffCount  + 1;
            end
        else
            if TDerDiff < -1
                ToffTest = 0;
            else
                ToffCount = ToffCount  + 1;
            end
        end
    end
    
    % Update the Poff Index
    ToffTempIndex = ToffTempIndex + ToffCount + 1;

    % Save the Index
    Index.Toff = [Index.Toff ToffTempIndex];
end

end
end




