function sac2strucwrap(localTeleDir, mname, modelname)
% Written by Evan Zhang
%
% function to wrap up sac files into matlab structure
% Input
% mname (model name for save) and no (model index).
% the program will look for (Eg. when no = 1) sim1RFR*sac and sim1RFT*sac,
% read them in, and wrap them up into (Eg. mname = 'test') test1_syn.mat

% load RFs into Matlab variables

% Dir = strcat(localTeleDir,'sactmp_new/');
Dir = localTeleDir; % temporary

% modelname = 'NM_OCLA_RF'; % model name in python code; default = 'sim';

% numR = size(dir([ strcat(Dir, modelname,int2str(no),'RFR*sac')]),1);
% numT = size(dir([ strcat(Dir, modelname,int2str(no),'RFT*sac')]),1);

numR = size(dir([ strcat(Dir, modelname,'/',mname,'.R*sac')]),1);
numT = size(dir([ strcat(Dir, modelname,'/',mname,'.T*sac')]),1);

rRF = zeros(numR-1,2500); % based on npts defined in porter.py % /2??????
tRF = zeros(numT-1,2500);

% for iR = 1:numR
%     RFR = readsac(strcat(Dir,modelname,int2str(no),'RFR',num2str(iR,'%02.f'),'.sac'));
%     rRF(iR,:) = RFR.DATA1(2501:5000);
% end
% 
% for iT = 1:numT
%     RFT = readsac(strcat(Dir,modelname,int2str(no),'RFT',num2str(iT,'%02.f'),'.sac'));
%     tRF(iT,:) = RFT.DATA1(2501:5000);
% end

for iR = 1:numR
    RFR = rdsac(strcat(Dir,modelname,'/',mname,'.R',num2str(iR,'%02.f'),'.sac'));
    rRF(iR,:) = RFR.d(2501:5000);
end

for iT = 1:numT
    RFT = rdsac(strcat(Dir,modelname,'/',mname,'.T',num2str(iT,'%02.f'),'.sac'));
    tRF(iT,:) = RFT.d(2501:5000);
end

% define the time and slowness vectors
bgntime = RFT.HEADER.B;
srate = RFT.HEADER.DELTA;
npts = RFT.HEADER.NPTS/2;
endtime = srate*(npts-1);
time = linspace(bgntime,srate*(npts-1),npts);
slow = 0.04:0.002:0.08-0.002; % how to interact with python code?

% save

% save(strcat(localTeleDir,'matfiles/',mname,int2str(no),'_syn'), 'rRF', 'tRF', 'bgntime', 'endtime'...
%     , 'srate', 'npts', 'time', 'slow');

save(strcat(localTeleDir,'matfiles/',mname,'_syn'), 'rRF', 'tRF', 'bgntime', 'endtime'...
    , 'srate', 'npts', 'time', 'slow');

