function [ Interval, Segment, Value, Duration, Count ] = Calculation....
    ( Index,Fail,fs,Buffer,Interval,Segment,Value,Duration,Count,IsAstro)
% This function calculates the length of the relevant segments of the ECG
%
% Inputs: 
% Index : Contains the indices of the PQRST waves
% Fail  : Determines whether a wave was detected or misssed
% fs    : Sampling frequency
%
% Outputs  :
% Interval : Conatins RR PR QT QTc Intervals
% Segment  : Contains PR ST Segments and QRS Complex
% Value    : Contains AverageST STIndex IsoIndex Iso STMeasurement
% Duration : Contains P and T waves durations
%
% Additional Comments:
% If the value of any of these segments or intervals is zero then it
% indicates a missed detection
% RR Interval Iso and STMeasurement length  is one less than other elements
% length


%% Calculate RR Interval
% It's the difference between two consecutive peaks
Interval.RR = diff(Index.R);
Interval.RRIndex = Index.R(1:end-1);

% Counters to keep track of the waves

% Used in P wave Duration
PDurCount = Count.P;
% Used in T wave Duration
TDurCount = Count.T;
% Used in PR Interval
PRCountP  = Count.PRP;
PRCountQ  = Count.PRQ;
PRCount   = Count.PR;
% Used in QT Interval
QTCountQ  = Count.QTQ;
QTCountT  = Count.QTT;
QTCount   = Count.QT;
% Used in PR Segment
PRSCountP = Count.PRSP;
PRSCountQ = Count.PRSQ;
PRSCount  = Count.PRS;
% Used in ST Segment
STSCountS = Count.STSS;
STSCountT = Count.STST;
STSCount  = Count.STS;
% Used in QRS Complex
QRSCountQ = Count.QRSQ;
QRSCountS = Count.QRSS;
QRSCount  = Count.QRS;
% Used in Isoelectric Baseline
IsoCountT = Count.IsoT;
IsoCountP = Count.IsoP;
IsoCount  = Count.Iso;

% Beginning of the loop
Start = length(Duration.P) + 1;

% When this loop runs more than once the last element of the old loop will
% overlap with the first element of the new loop. This is intentional since
% in the case of Iso calculation we need two consecutive heart beats so we
% will use the last old heart beat and the first new heart beat
for i = Start:length(Index.R)
    
    %% Calculate P wave duration
    if Fail.P(i) == 1
        PDurCount = PDurCount + 1;
        
        % Get number of missed P waves before i location
        
        
        Duration.P(i) = Index.Poff(PDurCount) - Index.Pon(PDurCount);
    else
        Duration.P(i) = 0;
    end
    
    %% Calculate T wave duration
    if Fail.T(i) == 1
        TDurCount = TDurCount + 1;
        Duration.T(i) = Index.Toff(TDurCount) - Index.Ton(TDurCount);
    else
        Duration.T(i) = 0;
    end
    
    %% Calculate PR Interval
    % It begins at the onset of a P wave -> onset of a Q wave
    
    % If both Q and T waves were found do the calculation
    if Fail.P(i) + Fail.Q(i) == 2
        
        % Counter for everytime the if statement was valid
        PRCount = PRCount + 1;
        
        % Store the difference in i location
        Interval.PR(i) = Index.Qon(PRCount + PRCountQ) - ...
            Index.Pon(PRCount + PRCountP);
        
        Interval.PRIndex(i) = Index.Pon(PRCount + PRCountP);
    else
        % Cases where P or Q was not found will be filled with zero
        Interval.PR(i)      = 0;
        Interval.PRIndex(i) = 0;
        
        % If a P wave was found but a Q wave was missed
        if Fail.P(i) == 1
           PRCountP = PRCountP + 1;
        % If a Q wave was found but a P wave was missed
        elseif Fail.Q(i) == 1
            PRCountQ = PRCountQ + 1;
        end
    end
    
    %% Calculate QT Interval
    % It begins at the onset of a Q wave-> endpoint of a T wave
    
    % If both Q and T waves were found do the calculation
    if Fail.Q(i) + Fail.T(i) == 2
        
        % Counter for everytime the if statement was valid
        QTCount = QTCount + 1;
        
        % Store the difference in i location
        Interval.QT(i) = Index.Toff(QTCount + QTCountT) - ...
            Index.Qon(QTCount + QTCountQ);
        
        Interval.QTIndex(i) = Index.Qon(QTCount + QTCountQ);

    else
        % Cases where Q or T were not found will be filled with zero
        Interval.QT(i)      = 0;
        Interval.QTIndex(i) = 0;
        
        % If a P wave was found but a Q wave was missed
        if Fail.T(i) == 1
           QTCountT = QTCountT + 1;
        % If a Q wave was found but a P wave was missed
        elseif Fail.Q(i) == 1
            QTCountQ = QTCountQ + 1;
        end
        
    end
    
    %% Calculate PR Segment
    % It begins at the endpoint of a P wave -> onset of a Q wave
    
    % If both P and Q waves were found do the calculation
    if Fail.P(i) + Fail.Q(i) == 2
        
        % Counter for everytime the if statement was valid
        PRSCount = PRSCount + 1;        
        
        % Store the difference in i location
        Segment.PR(i) = Index.Qon(PRSCount + PRSCountQ) - ...
            Index.Poff(PRSCount + PRSCountP);
        Segment.PRIndex(i) = Index.Poff(PRSCount + PRSCountP);
    else
        % Cases where P or Q were not found will be filled with zero
        Segment.PR(i) = 0;
        Segment.PRIndex(i) = 0;
        
        % If a P wave was found but a Q wave was missed
        if Fail.P(i) == 1
           PRSCountP = PRSCountP + 1;
        % If a Q wave was found but a P wave was missed
        elseif Fail.Q(i) == 1
            PRSCountQ = PRSCountQ + 1;
        end
        
    end
    
    %% Calculate ST Segment and Average ST
    % It begins at the endpoint of an S wave -> onset of a T wave
    
    % If both S and T waves were found do the calculation
    if Fail.S(i) + Fail.T(i) == 2
        
        % Counter for everytime the if statement was valid
        STSCount = STSCount + 1;   
        
        % Store the difference in i location
        Segment.ST(i) = Index.Ton(STSCount + STSCountT) - ...
            Index.Soff(STSCount + STSCountS);
        Segment.STIndex(i) = Index.Soff(STSCount + STSCountS);
        
        % Calculate the range for averging
        STRange = Index.Soff(STSCount + STSCountS):...
            Index.Ton(STSCount + STSCountT);

        % If STRange is so low take Ton as the AverageST
        if length(STRange) < 2
            % Find the mean of the ECG during the specific range
            Value.AverageST(i) = mean(Buffer.Plot(Index.Ton(STSCount...
                + STSCountT)));
            Value.STIndex(i)   = Index.Soff(STSCount + STSCountS);
        else
            % Find the mean of the ECG during the specific range
            Value.AverageST(i) = mean(Buffer.Plot(STRange));
            Value.STIndex(i)   = Index.Soff(STSCount + STSCountS);
        end
        
    else
        % Cases where S or T were not found will be filled with zero
        Segment.ST(i)      = 0;
        Segment.STIndex(i) = 0;
        Value.AverageST(i) = 0;
        Value.STIndex(i)   = 0;
        
        % If a P wave was found but a Q wave was missed
        if Fail.T(i) == 1
           STSCountT = STSCountT + 1;
        % If a Q wave was found but a P wave was missed
        elseif Fail.S(i) == 1
            STSCountS = STSCountS + 1;
        end
    end
    
    %% Calculate QRS Complex
    % It begins at the onset of a Q wave -> endpoint of an S wave
    
    % If both Q and S waves were found do the calculation
    if Fail.Q(i) + Fail.S(i) == 2
        
        % Counter for everytime the if statement was valid
        QRSCount = QRSCount + 1;
        
        % Store the difference in i location
        Segment.QRS(i) = Index.Soff(QRSCount + QRSCountS) - ...
            Index.Qon(QRSCount + QRSCountQ);
        Segment.QRSIndex(i) = Index.Qon(QRSCount + QRSCountQ);
        if IsAstro
        if Segment.QRS(i) > (120*fs/1000)
            Segment.QRS(i) = Index.S(QRSCount + QRSCountS) - ...
                Index.Q(QRSCount + QRSCountQ) + round(30*fs/1000);
            Segment.QRSIndex(i) = Index.Q(QRSCount + QRSCountQ);
        end
        end
        
    else
        % Cases where Q or S were not found will be filled with zero
        Segment.QRS(i) = 0;
        Segment.QRSIndex(i) = 0;
        
        % If a P wave was found but a Q wave was missed
        if Fail.Q(i) == 1
           QRSCountQ = QRSCountQ + 1;
        % If a Q wave was found but a P wave was missed
        elseif Fail.S(i) == 1
            QRSCountS = QRSCountS + 1;
        end
        
    end
    
    %% Calculate Isoelectric Baseline
    % It is the flat part of the ECG
    % Calculated by averging the points between two consecutive heart beats
    % Mean of points between endpoint of a T wave -> on set of a P wave
    
    Loc = i;
    Bool = true;
    TempIsoCount  = IsoCount ;
    TempIsoCountT = IsoCountT;
    
    % When the end of the loop arrives find Iso and ST measurement from the
    % difference between the waves of first new loop and last old loop
    if i == length(Index.R)
        Loc = Start - 1;

        
        % If loc < 1 then the detection just started we cannot check with
        % old pulses
        if Loc < 1
            Bool = false;
            Loc = 1;
            
            if Fail.T(i) == 1
                TempIsoCountT = TempIsoCountT + 1;
            end
        
        else
            NewIsoCount   = TempIsoCount;
            if Fail.T(Loc) == 1
                NewIsoCountT  = TempIsoCountT - 1;
            else
                NewIsoCountT  = TempIsoCountT;
            end
            TempIsoCount  = Count.Iso;
            if Fail.T(Loc) == 1
                TempIsoCountT = Count.IsoT - 1;
            else
                TempIsoCountT = Count.IsoT;
            end
        end

    end
    % Prevent negative indexing
    if length(Fail.P) >= Loc+1
    if (Fail.T(Loc) + Fail.P(Loc+1) == 2 ) && Bool
        
        % Counter for everytime the if statement was valid
        TempIsoCount = TempIsoCount + 1;
        
        if exist('NewIsoCount','var')
            NewIsoCount  = NewIsoCount + 1;
        end
        
        Temp = Index.Pon>Index.Toff(TempIsoCount + TempIsoCountT) &...
            Index.Pon<Index.Toff(TempIsoCount + TempIsoCountT) + 500*fs/1000;
        
        IsoRange = Index.Toff(TempIsoCount + TempIsoCountT):...
            Index.Pon(Temp);
        
        Value.Iso(Loc)      = mean(Buffer.Plot(IsoRange));
        Value.IsoIndex(Loc) = Index.Toff(TempIsoCount + TempIsoCountT);
        
    elseif Bool
        % Cases where P or T were not found will be filled with zero
        Value.Iso(Loc)      = 0;
        Value.IsoIndex(Loc) = 0;
        
       
        if exist('NewIsoCountT','var') && Fail.T(Loc) == 1
            NewIsoCountT  = NewIsoCountT + 1;
        end
        
        if Fail.T(Loc) == 1
            TempIsoCountT = TempIsoCountT + 1;
        end     
    end
    end


    if exist('NewIsoCount','var')
        IsoCount  = NewIsoCount;
    else
        IsoCount  = TempIsoCount;
    end
    
    if exist('NewIsoCountT','var')
        if Fail.T(i) == 1 %&& Fail.P(i) == 1
            IsoCountT  = NewIsoCountT + 1;
        else
            IsoCountT  = NewIsoCountT;
        end
            
    else
        IsoCountT  = TempIsoCountT;
    end

    
    %% Calculate ST Measurement(Elevation - Depression)
    % It is AverageST - Isoelectric Baseline
    
    % Prevent negative indexing
    if length(Value.Iso) >= Loc
    if Value.Iso(Loc) ~= 0 && Segment.ST(Loc)~= 0 
        Value.STMeasurement(Loc) = Value.AverageST(Loc) - Value.Iso(Loc);
    else
        Value.STMeasurement(Loc) = 0;
    end
    else
        Value.STMeasurement(Loc) = 0;
    end
end


%% Perform Bazett's calculation for QTc
% Cases were Q or T were not found will be filled with zero

Start = length(Interval.QTc) + 1;

for i = Start:length(Interval.QT)
    if length(Interval.RR) >= 1
    if i < length(Interval.RR)
        Interval.QTc(i) = (Interval.QT(i))/(sqrt(Interval.RR(i)/fs));
    else
        Interval.QTc(i) = (Interval.QT(i))/(sqrt(Interval.RR(end)/fs));
    end
    else
        Interval.QTc(i) = 0;
    end
end

%% Save the counters
Count.P    = PDurCount;
Count.T    = TDurCount;
Count.PRP  = PRCountP ;
Count.PRQ  = PRCountQ ;
Count.PR   = PRCount  ;
Count.QTQ  = QTCountQ ;
Count.QTT  = QTCountT ;
Count.QT   = QTCount  ;
Count.PRSP = PRSCountP;
Count.PRSQ = PRSCountQ;
Count.PRS  = PRSCount ;
Count.STSS = STSCountS;
Count.STST = STSCountT;
Count.STS  = STSCount ;
Count.QRSQ = QRSCountQ;
Count.QRSS = QRSCountS;
Count.QRS  = QRSCount ;
Count.IsoT = IsoCountT;
Count.IsoP = IsoCountP;
Count.Iso  = IsoCount ;

end










