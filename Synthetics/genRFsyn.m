function genRFsyn(Dz, rho, Vp, Vs, Vperc, Trend, ...
    Plunge, modelDir, modname)
% Written by Evan Zhang
%
% function to generate model file for telewavesim
% Input
% model parameters for each layer - self interpretable; no - model index
% all inputs are in vector, Eg. Dz = [0.7 35 0] -> 0.7km (sediment), 35 km
% (crust), and infinite mantle
%
% the program will generate a model file called WavesimMod1.txt (Eg. no =
% 1)

% built the model

model.Dz = Dz ;
model.rho = rho;
model.Vp = Vp ;
model.Vs = Vs ;
model.Vperc = Vperc;
model.Trend = Trend ;
model.Plunge = Plunge;
matmod2txt_noprem(model, modelDir, modname)

end

