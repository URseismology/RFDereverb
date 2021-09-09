% Telewavesim Workflow
% Author: Evan Zhang
%
% Input: (1) layered structure,
%        (2) ray parameters.
%
% Output: MatLab structure, containing
%            (1) synthetic RF traces,
%            (2) time vector,
%            (3) bin vector (epicentral distances).

%% Parameters Setup

% directory

localBaseDir = '/scratch/tolugboj_lab/';
workDir = [localBaseDir 'Prj4_Nomelt/seus_test/evan/'];
modelDir = [workDir 'model/'];
sacDir = [workDir 'sac/'];
matDir = [workDir 'matfile/'];

% volocity model

modname = 'sim';

Dz = [100 12 0];
rho = [3000 2700 3000];
Vp = [8.1 6.0 8.1];
Vs = [4.5 3.4 4.5];
Vperc = [0.0 0.0 0.0];
Trend = [0.0 0.0 0.0];
Plunge = [0.0 0.0 0.0];

% ray parameter

rayp_file = [workDir 'rayP/linspace.txt'];

% options

DelSac = 0;

%% Make Velocity Model File
% This section generates velocity model file based on your input strucrure.

genRFsyn(Dz, rho, Vp, Vs, Vperc, Trend, Plunge, modelDir, modname);

%% Run Telewavesim Python Program
% This section calls a bash script to run the Telewavesim program.

system('./job_Telewavesim.sh');

%% Wrap Output SAC Files into MatLab Structure
% This section reads the output files of Telewavesim program and wrap them
% into a MatLab structure for further analysis.

slow = load(rayp_file);
[garc, ~] = raypToEpiDist(slow, 0, 1, localBaseDir);

sac2strucwrap(sacDir, matDir , modname, garc);

if DelSac
    DelCmd = strcat('rm -f ',sacDir,'*sac');
end





