%
% Give realistic rayP for telewavesim synthetic RF analysis
% based on EQ data on  SEUS transects
%
% Author: Evan Zhang
%

% load in EQ mat file
EQmat = load('../TELEWAVEISM/EQatZZ.mat');

for i = 1:length(EQmat.EQCCP) - 1 % no data in last one (ZZ)
    
    thisEQCCP = EQmat.EQCCP(i);
    
    garc = zeros(length(thisEQCCP.EQmeta),1);
    
    for iEQ = 1:length(thisEQCCP.EQmeta)
        
        garc(iEQ) = thisEQCCP.EQmeta(iEQ).evDistDeg;
        
    end
    
    [~, rayP] = raypToEpiDist(garc, 1, 0, localBaseDir);
    
    rayPfile = strcat('SEUS_ZZ_CCP_',num2str(i,'%02d'),'.txt');
    rayPfolder = strcat(localBaseDir,'Prj4_Nomelt/seus_test/evan/rayP/');
    
    if ~exist(rayPfolder, 'dir')
       mkdir(rayPfolder);
    end
    
    fileID = fopen(strcat(rayPfolder,rayPfile),'w');
    fprintf(fileID,'%10.8f\n',rayP);
    fclose(fileID);
    
end