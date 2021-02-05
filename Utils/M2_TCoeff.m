% Calculate energy/amplitude of Ps phases and multiples from LAB & Moho
% from transmission coefficients
%
% Written by Evan Zhang

% Define layer structures

ms = [2.00 0.50 2000];
mc = [6.50 3.65 2800];
mm = [8.10 4.50 3300];
mh = [8.10 4.10 3200];
mf = [0.33 0.001 1.225];

% ms = mc; % for M1

p = 0.08;

% Calculate transmission coefficient matrices for each interface

LAB_U = PSVRTmatrix(p,mh,mm);
MOH_U = PSVRTmatrix(p,mm,mc);
SED_U = PSVRTmatrix(p,mc,ms);
FRE_U = PSVRTmatrix(p,ms,mf);

LAB_D = PSVRTmatrix(p,mm,mh);
MOH_D = PSVRTmatrix(p,mc,mm);
SED_D = PSVRTmatrix(p,ms,mc);
FRE_D = PSVRTmatrix(p,mf,ms);

% Direct P

P    = LAB_U(5) * MOH_U(5) * SED_U(5);

% LAB phases

PlS  = LAB_U(6) * MOH_U(7) * SED_U(7);
PPlS = LAB_U(5) * MOH_U(5) * SED_U(5) * FRE_U(1) * SED_D(5) * MOH_D(5) * ...
    LAB_D(2) * MOH_U(7) * SED_U(7);
PSlS = LAB_U(5) * MOH_U(5) * SED_U(5) * FRE_U(2) * SED_D(7) * MOH_D(7) * ...
    LAB_D(3) * MOH_U(7) * SED_U(7);

% Moho phases

PmS  = LAB_U(5) * MOH_U(6) * SED_U(7);
PPmS = LAB_U(5) * MOH_U(5) * SED_U(5) * FRE_U(1) * SED_D(5) * MOH_D(2) * ...
    SED_U(7);
PSmS = LAB_U(5) * MOH_U(5) * SED_U(5) * FRE_U(2) * SED_D(7) * MOH_D(3) * ...
    SED_U(7);

% Normalization

NF   = 1;

P    = P/NF;
PmS  = PmS/NF;
PPmS = PPmS/NF;
PSmS = PSmS/NF;
PlS  = PlS/NF;
PPlS = PPlS/NF;
PSlS = PSlS/NF;

MM = abs(PmS) + abs(PPmS) + abs(PSmS);
LL = abs(PlS) + abs(PPlS) + abs(PSlS);

% Print
fprintf('Model M2\n');
fprintf('Phase   Amplitude   Weight\n');
fprintf('P    %12.4f\n',P);
fprintf('PmS  %12.4f %7.2f%%\n',PmS,PmS/MM*100);
fprintf('PPmS %12.4f %7.2f%%\n',PPmS,PPmS/MM*100);
fprintf('PSmS %12.4f %7.2f%%\n',PSmS,PSmS/MM*100);
fprintf('PlS  %12.4f %7.2f%%\n',PlS,PlS/LL*100);
fprintf('PPlS %12.4f %7.2f%%\n',PPlS,PPlS/LL*100);
fprintf('PSlS %12.4f %7.2f%%\n',PSlS,PSlS/LL*100);