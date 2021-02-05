function [flted] = filterRF(rrfAmpArray,timeAxisHD,binAxisHD)
% Written by Evan Zhang
%
% function to filter the RF.
%
% Input:
% rrfAmpArray - radial RF, timeAxisHD - time vector,
% binAxisHD - epicentral distances bins.
%
% Output:
% flted - filtered RF.


clear i;

% frequency setup
Dt = timeAxisHD(2) - timeAxisHD(1);
N = length(timeAxisHD);

fmax = 1/(2.0*Dt);
df = fmax/(N/2);
f = df*[0:N/2,-N/2+1:-1]';
Nf = N/2+1;
dw = 2.0*pi*df;
w = dw*[0:N/2,-N/2+1:-1]';

% figure(1);
% clf;

for iRF = 1:size(rrfAmpArray,1)
    %     iRF
    
    % autocorrelation
    
    D = rrfAmpArray(iRF,:);
    D = D';
    D = D - mean(D);
    D = detrend(D);
    %     D  = lowpass(D, (1/Dt),  1, 4, 2, 'butter'); % 3rd input = freq
    
    ac = xcorr(D);
    ac = ac./max(ac);
    ac = ac(N:2*N-1);
    
    % fit a decaying sinusoid - from Cunningham et al. (2019)
    %         [sigr,resr] = fit_damped_sinewave(ac);
    %         tlag = (pi / resr(3)) * Dt;
    %         r0 = - sigr(round(pi / resr(3)));
    
    %         % old method: just find peaks of autocorrelation
    %             rac = (-1)*ac;
    %             [pks,locs] = findpeaks(rac);
    %             r0 = abs(pks(1)); tlag = locs(1)*Dt;
    
    % Alternatively, give r0 and tlag based on velocity models
    
    v = 0.25;
    H = 0.25;
    p = binAxisHD(iRF);
    tlag = (2*H/v) * sqrt(1-v^2*p^2);
    tlagw = (2*5/1.5) * sqrt(1-1.5^2*p^2);
    
    mw = [1.5 0.0001 1027];
    ms = [2.10 0.25 2000];
    mc = [7.00 3.65 2800];
    
    [RTmatrix] = PSVRTmatrix(p,ms,mc);
    [RTmatrixw] = PSVRTmatrix(p,ms,mw); % mc or ms
    r0 = abs(RTmatrix(3));
    rw = abs(RTmatrixw(1));
    
    
    % build the filter
    
    % only water
    
    %     flt = (1+rw*exp(-1i*w*tlagw));
    %     flted(iRF,:) = real( ifft(fft(D).*flt) );
    %     flted(iRF,:) = flted(iRF,:) ./ max(flted(iRF,:));
    
    % sediment
    flt = (1+r0*exp(-1i*w*tlag));
    flted(iRF,:) = real( ifft(fft(D).*flt) );
    flted(iRF,:) = flted(iRF,:) ./ max(flted(iRF,:));
    
    % water
    %     fltw = (1+rw*exp(-1i*w*tlagw));
    %     flted(iRF,:) = real( ifft(fft(flted(iRF,:)').*fltw) );
    %     flted(iRF,:) = flted(iRF,:) ./ max(flted(iRF,:));
    
    
    
    plot(timeAxisHD, (iRF-1) + real(flted(iRF,:)), 'k', 'linewidth', 2)
    hold on;
    plot(timeAxisHD, (iRF-1) + (D./max(D)),'b', 'linewidth', 0.5)
    hold on;
    
end

sumRF = sum(flted,1);
sumRF = sumRF/20;

% plot(timeAxisHD, 0.2*(10) + sumRF,'r', 'linewidth', 3);
% 
% xlim([-2 16]);
% ylim([-1 size(rrfAmpArray,1)+1]);
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

