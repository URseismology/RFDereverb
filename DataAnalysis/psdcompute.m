function [f,Nf,s2noiMean,s2sigMean] ...
    = psdcompute(localBaseDir,station,cmp,method)
% Author: Evan Zhang
%
% Compute PSD for signals and noises of filtered seismograms
%
% cmp = 1 - conventional; cmp = 2 - jLab

clear s2*

evtnm = 'test';

ii = 1;
jj = 1;

% load data
 
 maindir = strcat(localBaseDir,'Prj4_Nomelt/2_Data/SAC/XO/',station,'/');
 fid = fopen(strcat(localBaseDir,'Prj4_Nomelt/2_Data/meta_Data/ZA/ZA.in'));
 while ischar(evtnm)
     clear evtnm;
     evtnm = fgetl(fid);
     if ~ischar(evtnm)
         continue;
     end
     if strcmp(evtnm(66:68),station)
         sacnm(ii) = string(strcat(evtnm(63:end),cmp));
         ii = ii + 1;
     end
 end



for i = 1:length(sacnm)
    
    if ~isfile(char(fullfile(maindir,sacnm(i))))
        continue;
    end
    S = readsac(char(fullfile(maindir,sacnm(i))));
    
    nofsamp = S.NPTS;
    tt = 0:S.DELTA:(nofsamp-1)*S.DELTA;
    
    trace = S.DATA1;
    srate = round(1/S.DELTA);
    
    trace = detrend(trace);
    trace = trace-mean(trace);
    
    Nb = round(60/S.DELTA); Ne = round(120/S.DELTA)-1;
    Pb = round(120/S.DELTA); Pe = round(180/S.DELTA)-1;
    
    if Pe > nofsamp
        continue;
    end
    
    dnoi = trace(Nb:Ne); % noise
    dsig = trace(Pb:Pe); % signal
    
    Dt = S.DELTA;
    N = length(dsig);
    
    % generic t/f setup
    
    t = Dt*[0:N-1]';
    tmax = Dt*(N-1);
    fmax = 1/(2.0*Dt);
    Df = fmax/(N/2);
    f = Df*[0:N/2,-N/2+1:-1]';
    Nf = N/2+1;
    
    % compute psd
    
    switch method
        
        case 1
            % CONVENTIONAL
            % for noise
            dnoiBar = Dt*fft(dnoi);
            s2noi(jj,:) = (2/(N*Dt)) * abs(dnoiBar(1:Nf)).^2;
            
            % for signal
            dsigBar = Dt*fft(dsig);
            s2sig(jj,:) = (2/(N*Dt)) * abs(dsigBar(1:Nf)).^2;
            
        case 2
            % JLAB
            n2 = length(dsig);
            P = 2;
            K = 2*P-1;
            [PSI,~] = sleptap(n2,P,K);
            [~,s2sig(jj,:)] = mspec(dsig,PSI,'detrend');
            [~,s2noi(jj,:)] = mspec(dnoi,PSI,'detrend');
            
            
    end
    
    
    jj = jj+1;
    
end

fprintf('%d records\n',jj);
s2noiMean = mean(s2noi);
% s2noiMean = 0;
s2sigMean = mean(s2sig);

end
