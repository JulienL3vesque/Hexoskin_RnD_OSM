
function [] = PlotPoints( TimeStart, TimeEnd, Buffer, Index, fs, ...
    LongRQuality, Interval, Segment, Value, i, Time,RIndex)

[P, Q, R, S, T, ~,~, ~, ~, ~, ~,~,~] = UnselectBad(Index, ...
    LongRQuality, TimeStart, TimeEnd,fs,Buffer, Interval, Segment, Value,RIndex);

if i == 0 
    
   TimeStart = -1; 
elseif i-TimeStart<1
    TimeStart = 0;
end

RTemp = (R & Index.R <= Time(i-TimeStart)*fs & Index.R >= Time(1)*fs);
PTemp = (P & Index.P <= Time(i-TimeStart)*fs & Index.P >= Time(1)*fs);
QTemp = (Q & Index.Q <= Time(i-TimeStart)*fs & Index.Q >= Time(1)*fs);
STemp = (S & Index.S <= Time(i-TimeStart)*fs & Index.S >= Time(1)*fs);
TTemp = (T & Index.T <= Time(i-TimeStart)*fs & Index.T >= Time(1)*fs);

    
if ~isempty(RTemp)
    hold on,scatter(Index.R(RTemp)./fs,Buffer.Plot(Index.R(RTemp)),'r');
end
if ~isempty(PTemp)
    hold on,scatter(Index.P(PTemp)./fs,Buffer.Plot(Index.P(PTemp)),50,'d');
    %hold on,scatter(Index.Pon(PTemp)./fs,Buffer.Plot(Index.Pon(PTemp)),50,'d');
    %hold on,scatter(Index.Poff(PTemp)./fs,Buffer.Plot(Index.Poff(PTemp)),50,'d');
end
if ~isempty(QTemp)
    hold on,scatter(Index.Q(QTemp)./fs,Buffer.Plot(Index.Q(QTemp)),'k');
    %hold on,scatter(Index.Qon(QTemp)./fs,Buffer.Plot(Index.Qon(QTemp)),'k');
end
if ~isempty(STemp)
    hold on,scatter(Index.S(STemp)./fs,Buffer.Plot(Index.S(STemp)),'b');
    %hold on,scatter(Index.Soff(STemp)./fs,Buffer.Plot(Index.Soff(STemp)),'b');

end
if ~isempty(TTemp)
    hold on,scatter(Index.T(TTemp)./fs,Buffer.Plot(Index.T(TTemp)),'filled','d');
    %hold on,scatter(Index.Ton(TTemp)./fs,Buffer.Plot(Index.Ton(TTemp)),'filled','d');
    %hold on,scatter(Index.Toff(TTemp)./fs,Buffer.Plot(Index.Toff(TTemp)),'filled','d');
end

end
