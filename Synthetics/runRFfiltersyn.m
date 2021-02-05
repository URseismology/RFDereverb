function runRFfiltersyn(Dz, rho, Vp, Vs, Vperc, Trend, ...
    Plunge, localTeleDir, mname)
% generate and filter synthetic RF using given model parameter
%
% Dz, rho, Vp, Vs, Vperc, Trend, Plunge are model parameter vectors
%
% Eg. Dz = [0.7 35 0]
%
% Dz: layer thickness; define the last one as zero to indicate half space
%
% localTeleDir: your telewavesim directory
%
% mname: your model name
%
% after running, you should see mname_syn.mat & mname_syn_filtered.mat in
%   your localTeleDir, storing the original and filtered synthetic RFs

[~, ~, ~, ~] = genRFsyn(Dz, rho, Vp, Vs, Vperc, Trend, ...
    Plunge, localTeleDir, mname);

[~] = filterRFfunc(localTeleDir, mname);


