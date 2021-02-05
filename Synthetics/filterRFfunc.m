function filterRFfunc(localTeleDir, mname)
% Written by Evan Zhang
%
% function to filter the RF (generated from crust + sediment model).
% Input
% mname (model name).
% the progrma will look for (Eg. mname = 'test') test_syn.mat and
% apply the dereverberation filter to the radial RF (rRF in the matlab
% structure), and save it in a new file called test_syn_filtered.mat

clear i;

Dir = localTeleDir;
% sname = strcat(Dir, 'matfiles/',mname,int2str(no),'_syn.mat');
sname = strcat(Dir, 'matfiles/',mname,'_syn.mat');
S = load(sname);

RF = S.rRF;
Dt = S.srate;
N = S.npts;
tt = linspace(0, S.endtime, N);

flted = zeros(size(S.rRF,1),N);

% frequency setup

fmax = 1/(2.0*Dt);
df = fmax/(N/2);
f = df*[0:N/2,-N/2+1:-1]';
Nf = N/2+1;
dw = 2.0*pi*df;
w = dw*[0:N/2,-N/2+1:-1]';

% figure(1);
% clf;

for iRF = 1:20 % number of traces
%     iRF
    
    % autocorrelation
    
    D = RF(iRF,:);
    D = D';
%     D = lowpass(D,50,0.5,2,1,'butter','linear');
    D = lowpass(D, (1/Dt), 2, 4, 2, 'butter');
    
    ac = xcorr(D);
    ac = ac./max(ac);
    ac = ac(N:2*N-1);
    rac = (-1)*ac;
    
    [pks,locs] = findpeaks(rac);
    
    r0 = abs(pks(1)); tlag = locs(1)*Dt;
%     fprintf('autocorrelation results: r0 = %6.4f, tlag = %6.4f\n',r0,tlag);
    
    % build the filter
    
    
    flt = 1+r0*exp(-1i*w*tlag);

    flted(iRF,:) = real( ifft(fft(D).*flt) );
    
    flted(iRF,:)  = lowpass(flted(iRF,:), (1/Dt),  2, 4, 2, 'butter');
    
    flted(iRF,:) = flted(iRF,:) ./ max(flted(iRF,:));
    
    figure(1); clf;
    subplot(3,1,1)
    plot(tt,D./max(D));
%     xlim([0 20])
    title('Original RF');
    subplot(3,1,2)
    plot(tt,ac);
%     xlim([0 20])
    hold on;
    plot([locs(1)*Dt locs(1)*Dt],[min(get(gca,'YLim')) -pks(1)],'r');
    hold on;
    plot([min(get(gca,'XLim')) locs(1)*Dt],[-pks(1) -pks(1)],'r');
    hold on;
    title('Autocorrelation');
    subplot(3,1,3)
    plot(tt,flted(iRF,:));
%     xlim([0 20])
    title('Filtered RF');
    pause;

    
%     plot(tt, (iRF-1) + real(flted(iRF,:)), 'k', 'linewidth', 2)
%     hold on;
%     plot(tt, (iRF-1) + (D./max(D)),'b', 'linewidth', 0.5)
%     hold on;
    
end

sumRF = sum(flted,1);
sumRF = sumRF/20;

% plot(tt, 0.2*(10) + sumRF,'r', 'linewidth', 3);
% 
% xlim([-5 25]);
% ylim([-1 21]);
% 
% grid on;

% save new (filtered) structure

% nname = strcat(Dir, 'matfiles/',mname,int2str(no),'_syn_filtered.mat');
% nname = strcat(Dir, 'matfiles/',mname,'_syn_filtered.mat');
% copyfile(sname,nname);
% Sflted = load(nname);
% Sflted.rRF = flted;
% save(nname,'-struct','Sflted');

end

