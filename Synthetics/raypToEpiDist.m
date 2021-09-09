function [epiDist, rayP] = raypToEpiDist(value2flip, direction, localOrBluehive, localBaseDir) 
%   Authors: Liam P. Moser and Trey J. Brink 
%   This function allows the user to interchange epicentral distance and
%   ray paramter values. The interpolation is based off a data set of 
%   collected epicentral distance and ray parameter values for station that
%   is provided by the user. Duplicates are removed based on direction of
%   interpolation. It is up to user to determine valid interpolation
%   domain.
%   INPUT: value2flip = either a single ray parameter or epicentral
%   distance value. direction = whether you want to interpolate from epicentral
%   distance to ray parameter or vis versa. True = epiDist --> rayP, False
%   = rayP --> epiDist. dataToInterpt = 2 x n array where n = number of
%   datapoints. Row 1 should be epicental distance and row 2 ray parameter.
%   localOrBluhive specifies whether the interpretation data should be
%   loaded locally or on BH. True = BH, False = Local. locaBaseDir is your
%   local base directory that take you to bluehive. 
%   OUTPUT: epicentral distance and ray parameter. One will the one that
%   was passed and the other will be the interpolation. 

if localOrBluehive
    load('/scratch/tolugboj_lab/Prj2_SEUS_RF/2_Data/rayP2EpiDistData/US.GOGA_RayParamAndEpiDist.mat', 'z');
else
    load([localBaseDir '/Prj2_SEUS_RF/2_Data/rayP2EpiDistData/US.GOGA_RayParamAndEpiDist.mat'], 'z');
end

dataToInterp = z;
epiDistAll = dataToInterp(:, 1);
rayPAll = dataToInterp(:, 2);

if direction

    [epiDistUnique, i, ii] = unique(epiDistAll);
    rayPAllShort = rayPAll(i);
    rayP = interp1(epiDistUnique, rayPAllShort, value2flip, 'nearest');
    epiDist = value2flip;
    
else
    
    [rayPAllUnique, i, ii] = unique(rayPAll);
    epiDistShort = epiDistAll(i);
    epiDist = interp1(rayPAllUnique, epiDistShort, value2flip,'nearest');
    rayP = value2flip;

end