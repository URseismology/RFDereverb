function sac2strucwrap(sacDir, matDir, mname, garc)
% Author: Evan Zhang
%
% function to wrap up sac files into matlab structure
% Input
% mname (model name for save).
% the program will look for simRFR*sac and simRFT*sac,
% read them in, and wrap them up into (Eg. mname = 'test') test_syn.mat

% load RFs into Matlab variables

numR = size(dir([ strcat(sacDir, mname,'.R*sac')]),1);
numT = size(dir([ strcat(sacDir, mname,'.T*sac')]),1);

rRF = zeros(numR-1,2500); % based on npts defined in py % /2??????
tRF = zeros(numT-1,2500);

for iR = 1:numR
    RFR = rdsac(strcat(sacDir,mname,'.R',num2str(iR,'%02d'),'.sac'));
    rRF(iR,:) = RFR.d(2501:5000);
end

for iT = 1:numT
    RFT = rdsac(strcat(sacDir,mname,'.T',num2str(iT,'%02d'),'.sac'));
    tRF(iT,:) = RFT.d(2501:5000);
end

% define the time and slowness vectors

bgntime = RFT.HEADER.B;
srate = RFT.HEADER.DELTA;
npts = RFT.HEADER.NPTS/2;
endtime = srate*(npts-1);
time = linspace(bgntime,srate*(npts-1),npts);

% save

save(strcat(matDir,mname,'_syn.mat'), 'rRF', 'tRF', 'bgntime', 'endtime'...
    , 'srate', 'npts', 'time', 'garc');

