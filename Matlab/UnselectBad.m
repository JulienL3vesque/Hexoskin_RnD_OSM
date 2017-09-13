function [P, Q, R, S, T, RR, PR, QT, PRS, STS, QRS, AST, Iso] = UnselectBad...
    (Index, LongRQuality, Start, End, fs, Buffer, Interval, Segment, Value,RIndex)
% This function unselects the unwanted waves and returns an array that
% contain the locations for the points with good quality
%
% Input:
% Index       : Where the indicies are stored
% LongRQuality: Where the quality of the siganl is stored
% Start       : Location to start 
% End         : Location to end
% fs          : Sampling frequency
% Interval    : Contains RR PR QT QTc Intervals
% Segment     : Contains PR ST Segments and QRS Complex
% Value       : Contains AverageST IndexST Iso IsoIndex STMeasurement
%
% Output:
% P  : Includes the location of the wanted P waves
% Q  : Includes the location of the wanted Q waves
% R  : Includes the location of the wanted R waves
% S  : Includes the location of the wanted S waves
% T  : Includes the location of the wanted T waves
% PR : Includes the location of the wanted PR Interval
% QT : Includes the location of the wanted QT Interval
% PRS: Includes the location of the wanted PR Segment
% STS: Includes the location of the wanted ST Segment
% QRS: Includes the location of the wanted QRS Complex

% Select the waves between Start and End
P = (Index.P <= End & Index.P >= Start);
Q = (Index.Q <= End & Index.Q >= Start);
R = (Index.R <= End & Index.R >= Start);
S = (Index.S <= End & Index.S >= Start);
T = (Index.T <= End & Index.T >= Start);

% Select the Intervals and Segments between Start and End
RR  = (Interval.RRIndex <= End & Interval.RRIndex >= Start);
PR  = (Interval.PRIndex <= End & Interval.PRIndex >= Start);
QT  = (Interval.QTIndex <= End & Interval.QTIndex >= Start);
PRS = (Segment.PRIndex <= End & Segment.PRIndex >= Start);
STS = (Segment.STIndex <= End & Segment.STIndex >= Start);
QRS = (Segment.QRSIndex <= End & Segment.QRSIndex >= Start);
AST = (Value.STIndex <= End & Value.STIndex >= Start);
Iso = (Value.IsoIndex <= End & Value.IsoIndex >= Start);

% Unselect the R waves that are bellow the mean of the signal
SignalMean = mean(Buffer.Plot(Start+1:End+1));
% Search for bad signals
RTemp = (R & (Buffer.Plot(Index.R) < SignalMean));
% Change the Quality to 128 indicating a bad signal
LongRQuality(RTemp) = 128;

% Loop to unselect the data that come when we have a bad signal

% Counter will store the location of the first index of R wave that is
% between Start -> End
Counter = find(R == 1);
% Make sure it is not empty
if Counter
    % Take into consideration the last peak from the previous pulse
    if Counter(1) > 1
       CounterStart = Counter(1) - 1; 
       CounterEnd = CounterStart + length(Index.R(R)) + 1;
    else
        CounterStart = 1;
        CounterEnd = CounterStart + length(Index.R(R));
    end
else
    % Dont execute the loop
    CounterStart = 0;
    CounterEnd = -1;
end

% If CounterEnd is bigger than the Index.R reduce its size by (CounterEnd -
% length(Index.R)) =  1
if CounterEnd > length(Index.R)
    CounterEnd = CounterEnd + length(Index.R) - CounterEnd;
end

for i = 1:CounterEnd
   
    % When working with interval RR we need to end the search at 
    % CounterEnd - 1, since it uses two peaks
   if i < CounterEnd
   if Interval.RR(i) ~= 0 && LongRQuality(i) == 0 && RR(i)
       RR(i) = 1;
   else
       RR(i) = 0;
   end
   end
   
   if Interval.PR(i) ~= 0 && LongRQuality(i) == 0 && PR(i)
       PR(i) = 1;
   else
       PR(i) = 0;
   end
   
   if Interval.QT(i) ~= 0 && LongRQuality(i) == 0 && QT(i)
       QT(i) = 1;
   else
       QT(i) = 0;
   end

   if Segment.PR(i) ~= 0 && LongRQuality(i) == 0 && PRS(i)
       PRS(i) = 1;
   else
       PRS(i) = 0;
   end
   
   if Segment.ST(i) ~= 0 && LongRQuality(i) == 0 && STS(i)
       STS(i) = 1;
   else
       STS(i) = 0;
   end   

   if Segment.QRS(i) ~= 0 && LongRQuality(i) == 0 && QRS(i)
       QRS(i) = 1;
   else
       QRS(i) = 0;
   end
   
   if Value.AverageST(i) ~=0 && LongRQuality(i) == 0 &&...
           ~isnan(Value.AverageST(i)) && AST(i)
       
       AST(i) = 1;
   else
       AST(i) = 0;
   end
   
   % When working with interval RR we need to end the search at 
   % CounterEnd - 1, since it uses two peaks
   if i < CounterEnd
   if Value.Iso(i) ~=0 && LongRQuality(i) == 0 &&...
           ~isnan(Value.Iso(i)) && Iso(i)
       
       Iso(i) = 1;
   else
       Iso(i) = 0;
   end
   end
   
end

% Changing them to boolean
RR  = (RR  == 1);
PR  = (PR  == 1);
QT  = (QT  == 1);
PRS = (PRS == 1);
STS = (STS == 1);
QRS = (QRS == 1);
AST = (AST == 1);
Iso = (Iso == 1);

if isempty(RR)
   RR = []; 
end
if isempty(PR)
   PR = []; 
end
if isempty(QT)
   QT = []; 
end
if isempty(PRS)
   PRS = []; 
end
if isempty(STS)
   STS = []; 
end
if isempty(QRS)
   QRS = []; 
end
if isempty(AST)
   AST = []; 
end
if isempty(Iso)
   Iso = []; 
end

% We need a range that accomodates all the waves in the duration we
% selected that's why we search for the smallest Starting point
Temp1 = find(P==1);
Temp2 = find(Q==1);
Temp3 = find(S==1);
Temp4 = find(T==1);
if isempty(Temp1)||isempty(Temp2)||isempty(Temp3)||isempty(Temp4)
    Start = 1;
else
    Temp1 = Temp1(1);
    Temp2 = Temp2(1);
    Temp3 = Temp3(1);
    Temp4 = Temp4(1);

    if Temp1 >= Temp2
        Start = Temp2;
    else
        Start = Temp1;
    end

    if Start > Temp3
        Start = Temp3;
    elseif Start > Temp4
        Start = Temp4;
    end

end
if ~isempty(RIndex)
% Find difference between peaks
RR = diff(RIndex);

% Find if any difference is much greater than mean
% If much greater than mean then a peak might have been missed
% So change the mean
Temp = mean(RR)-30 < RR < mean(RR) + 30;
RR = mean(RR(Temp));

if ~isnan(RR)
    PWindowStart = round(RR*0.3);
    QWindow      = round(RR*0.12);
    SWindow      = round(RR*0.12);
    TWindowEnd   = round(RR*0.5);
else
    PWindowStart = round(200*fs/1000);
    QWindow      = round(80*fs/1000);
    SWindow      = round(80*fs/1000);
    TWindowEnd   = round(350*fs/1000);
end
else
    PWindowStart = round(200*fs/1000);
    QWindow      = round(80*fs/1000);
    SWindow      = round(80*fs/1000);
    TWindowEnd   = round(350*fs/1000);
end
for i = Start:length(Index.R)
    
    % Find the wave that is related to the R wave being analysed
    PRelatedR = Index.P >= Index.R(i)-PWindowStart & Index.P <= Index.R(i);
    QRelatedR = Index.Q >= Index.R(i)-QWindow & Index.Q <= Index.R(i);
    SRelatedR = Index.S >= Index.R(i) & Index.S <= Index.R(i)+SWindow;
    TRelatedR = Index.T >= Index.R(i) & Index.T <= Index.R(i) + TWindowEnd;
    
    % Sometimes a peak might be detected really close to another peak. This
    % is wrong detection and might lead to to waves related to one R, so we
    % only take the last wave and relate it to R.
    Temp = find(PRelatedR);
    for z = 1:size(Temp)-1
        PRelatedR(Temp(z)) = 0;
    end
    
    Temp = find(QRelatedR);
    for z = 1:size(Temp)-1
        QRelatedR(Temp(z)) = 0;
    end
    
    Temp = find(SRelatedR);
    for z = 1:size(Temp)-1
        SRelatedR(Temp(z)) = 0;
    end    
    
    Temp = find(TRelatedR);
    for z = 1:size(Temp)-1
        TRelatedR(Temp(z)) = 0;
    end
    
    % If the quality of the signal is bad unselect the wave
    if LongRQuality(i) ~= 0
        P(PRelatedR) = 0;
        Q(QRelatedR) = 0;
        R(i)         = 0;
        S(SRelatedR) = 0;
        T(TRelatedR) = 0;
    end
    
end
end
