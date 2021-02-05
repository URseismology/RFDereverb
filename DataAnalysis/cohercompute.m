function [ff,coherZR,coherZP] = cohercompute(network,station,localBaseDir,SN)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Code for computing slepian coherence using jlab in softwares
% Author: Tolulope Olugboji & Evan Zhang
%
% SN = 1: Signal, SN = 2: Noise
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load dataset here

cmp = {'Z';'R';'BDH.SAC'};

Twin = [2 5];
min_before = Twin(1);
min_after = Twin(2);

clear EQmeta;
load(strcat(localBaseDir,'Prj4_Nomelt/2_Data/SNR_Data/',network,'.',...
    station,'_EQmeta.mat'));

clear s2*

maindir = strcat(localBaseDir,'Prj4_Nomelt/2_Data/SAC/',network,'/',station,'/');
findfiles = char(strcat(maindir,network,'*..',cmp(1)));
files = dir(findfiles);

% load data and cut appropriately

nRecords = length(files);

for ii = 1:nRecords
    
    NoP = 0; % reset flag for pressure data
    nameNocmp = files(ii).name; iEv = str2num(nameNocmp(9:end-3));
    nameNocmp = nameNocmp(1:end-1);
    nameR = strcat(char(nameNocmp),char(cmp(2)));
    
    
    Z = readsac(char(fullfile(maindir,files(ii).name)));
    R = readsac( char( fullfile(maindir,nameR) ) );
    
    % ignore events with depth < 60 km & epicentral distance > 90
    
    nofsamp = Z.NPTS;
    tt = 0:Z.DELTA:(nofsamp-1)*Z.DELTA;
    
    % hamming taper
    
    W = zeros(nofsamp,1);
    Nw = floor(nofsamp/8);
    Wtmax = Z.DELTA*(nofsamp-1)/8;
    W(1:Nw)=0.54-0.46*cos(2*pi*[0:Nw-1]'/(Nw-1));
    
    
    
    % load Z, R and P
    for jj = 1:2 % 1:2 - ZR, 1:3 - ZRP
        
        switch jj
            case 1
                trace = Z.DATA1;
                Dt = Z.DELTA;
            case 2
                trace = R.DATA1;
                Dt = R.DELTA;
            case 3
                t0 = datetime(EQmeta(iEv).Time,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
                Tbeg = t0 - minutes(min_before) ;
                Tend = t0 + minutes(min_after) ;
                clear Ptrace;
                if station == 'WS71' || station == 'WS74' || station == 'WS75'
                    Ptrace = irisFetch.Traces(network,station,'*','BDH',Tbeg, Tend);
                else if station == 'LT17'
                        Ptrace = irisFetch.Traces(network,station,'*','EDH',Tbeg, Tend);
                    else
                        Ptrace = irisFetch.Traces(network,station,'*','HDH',Tbeg, Tend);
                    end
                end
                save(strcat(localBaseDir,'Prj4_Nomelt/3_Src/tmp_Pfiles/',...
                    network,'/',network,'.',station,'.',num2str(iEv),'.P.mat'),'Ptrace');
                load(strcat(localBaseDir,'Prj4_Nomelt/3_Src/tmp_Pfiles/',...
                    network,'/',network,'.',station,'.',num2str(iEv),'.P.mat'));
                % if no pressure data
                if isempty(Ptrace)
                    NoP = 1;
                    continue;
                end
                trace = Ptrace.data;
                srate = Ptrace.sampleRate;
                Dt = 1/srate;
        end
        
        
        trace = detrend(trace);
        trace = trace-mean(trace);
        %trace = W.*trace;
        
        %         [trace,loco] = bandpassZA(trace,srate,station);
        
        % windows for noise and signal
        Nb = round(60/Z.DELTA); Ne = round(120/Z.DELTA)-1;
        Pb = round(120/Z.DELTA); Pe = round(180/Z.DELTA)-1;
        
        if Pe > length(Z.DATA1)
            continue;
        end
        
        if SN == 1
            dd = trace(Pb:Pe); % signal
        else
            dd = trace(Nb:Ne); % noise
        end
        
        N = length(dd);
        
        % compute coherence here
        switch jj
            case 1
                Zt = dd;
            case 2
                Rt = dd;
            case 3
                Pt = dd;
        end
        
    end
    
    if Pe > length(Z.DATA1)
        continue;
    end
    
    % initialize running coherence, compute tapers once
    if ii == 1
        
        
        tsig = tt(Pb:Pe); % signal
        n2 = length(tsig);
        P = 2;    % -- see Park & Levin paper
        K = 2*P-1;
        [PSI,LAMBDA]=sleptap(n2,P,K);
        
        
        N = length(tsig);
        nF = N/2 + 1;
        zerovals2 = zeros(nRecords, nF);
        
        iCrosZR = complex(zerovals2,0);
        iCrosZP = complex(zerovals2,0);
        
        % generic t/f setup
        
        t = Dt*[0:N-1]';
        tmax = Dt*(N-1);
        fmax = 1/(2.0*Dt);
        Df = fmax/(N/2);
        f = Df*[0:N/2,-N/2+1:-1]';
        Nf = N/2+1;
        ff = f(1:Nf);
    end
    
    
    % compute ZR and ZP coherence
    for kk = 1:1 % 1:1 - ZR; 1:2 -ZR & ZP
        
        % set up slepian coherence here using the time window;
        X = Zt;
        
        if kk == 1
            Y = Rt;
        else
            Y = Pt;
        end
        
        [F,SXX,SYY,SXY]=mspec(Dt,X,Y,PSI);
        coher = (abs(SXY) ./ (sqrt(SXX) .* sqrt(SYY) )).^2;
        
        
        
        if kk == 1
            %coherZR = coher;
            iCrosZR(ii, :) = coher(:);
            iCrosZP(ii, :) = coher(:); % fake ZP coherence for output
        else
            %coherZT = coher;
            iCrosZP(ii, :) = coher(:);
        end
    end
    
    
    %     ff = F ./ (2* pi); % in cycles per seconds
    %plot(ff, abs(coherZR), 'color', [0.5 0.5 0.5]);
    %hold on
end


% signal coherence ...
realSpec1 = nansum( abs(iCrosZR),1 );%
mx1 = max(realSpec1);
coherZR = realSpec1 ./ mx1;

realSpec2 = nansum( abs(iCrosZP),1 );%
mx2 = max(realSpec2);
coherZP = realSpec2 ./ mx2;

end
