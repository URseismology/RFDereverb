function RFWigglePlot_SYN(matfile)

% Authors: Tolulope Olugboji, Liam Moser, Evan Zhang
% Plotting RF as traces, assist in visualizing data quality and selected
% arrival times.

%% Prepping values to be plotted from RF

tWin = [0 10];
epiDistRange = [30 95];
tSmWin = 0.25;

% RF variables
matRF = load(matfile);

rrfAmpArray = matRF.rRF;
timeAxisHD = matRF.time;
binAxisHD = matRF.slow;

% pct = linspace(1/4.5,0,21) * 100;

R = rrfAmpArray;

t = timeAxisHD; y = binAxisHD; nY = length(y);

rayP = y;
% sediment filter

figtitle = 'PLUME Original';


tStart = tWin(1); tEnd = tWin(2);

%Time window to smooth over where location conversion and reverberations
tSig = tSmWin/3.5; % Sets StDev so normal dist. encompases entire smoothing domain
it = find(t>tStart, 1); %Removing negative time
endt = find(t>tEnd, 1);

% finding the summary stack -- no weigthing
RR = R(:,it:endt);
sumR = sum(RR,  1);

%sumR = sum(weight .* RR,  1);

RSNorm = sumR./max(abs(sumR));
% wr = weight(1,:).*sign(RSNorm);

% ---- find stack non linear Nth root
Nr = 4; [nP, ~] = size(RR);
RNr = sign(RR) .* (abs(RR).^(1/Nr));
avgR = sum(RNr, 1) ./ nP;

RS_nr0= sign(avgR) .* (abs(avgR).^Nr);
RS_nr = RS_nr0 ./ max(abs(RS_nr0));

% calculate arrival times
% mohoTWinInitial = [1.8 2.2]; % (s) 2.5-5.5
% moveOutTWin = [0.2 1 1]; % [Ps PpPs PsPs] time window 0.5 2 2
% [mohoTimes, rayP, mohoSlope, mohoIntercept] = ...
%     mohoSelector(R, t, y, mohoTWinInitial, moveOutTWin, localBaseDir);
% mohoTimesLR = mohoIntercept + mohoSlope.*rayP;
% [PpsTimes, PssTimes] = mohoReverbTimes(mohoTimesLR', rayP', 6.5, 1.78);
% PpsTimes = PpsTimes + 0.42;

%% Plot pure RF traces with out weighting

h1 = figure(43);
clf

set(gcf,'position',[50,50,1000,1000])

subplot(5,3,1:15)
hold on

tshft = 0;

mm = max(abs(R(:,it:endt)), [] ,'all');
for iY = 1:nY
    
    Rn = R(iY,it:endt) ./ mm;
    Tn = t(it:endt); sizeT = length(Tn);
    
    yLev = (nY-iY);
    yVec = repmat(yLev, 1, sizeT);
    
    jbfill(Tn, max(Rn+yLev, yLev), yVec, [0 0 1],'k', 1, 1.0);
    jbfill(Tn, min(Rn+yLev, yLev), yVec, [1 0 0],'k', 1, 1.0);
    
    
    
end



% Plotting axis
yticks([0:5:nY]);
set(gca,'yticklabel', floor(linspace(epiDistRange(1),epiDistRange(2),(nY/5)+1)))
% set(gca,'xticklabel', '')
xlim([0 tEnd])
ylim([-1 nY+1])
%xlabel('Time (s)','FontSize', 24)
ylabel('Epicentral distance (deg)','FontSize', 20)

title([figtitle] ,'FontSize', 24)
grid on



