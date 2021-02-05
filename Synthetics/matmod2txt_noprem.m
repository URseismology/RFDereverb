function matmod2txt_noprem(modstruc, SACIN, no)

m = modstruc;
modelFile = [SACIN 'WavesimMod' int2str(no) '.txt'];

nZ = length(m.Dz);

modelParams{1} = '# Built with Matlab';
mLine = 1;

for iZ = 1:nZ
    
    col0 = num2str(m.Dz(iZ), '%6.3f \t');
    col1 = num2str(m.rho(iZ), '%6.3f \t');
    col2 = num2str(m.Vp(iZ), '%6.3f \t');
    col3 = num2str(m.Vs(iZ), '%6.3f \t');
    
    if m.Vperc(iZ) == 0
        col4 = 'iso';
        col5 = num2str(0, '%1.2f \t');
        col6 = num2str(0, '%1.2f \t');
        col7 = num2str(0, '%1.2f \t');
    else
        col4 = 'tri';
        col5 = num2str(m.Vperc(iZ), '%6.3f \t');
        col6 = num2str(m.Trend(iZ), '%6.3f \t');
        col7 = num2str(m.Plunge(iZ), '%6.3f \t');
    end
    
    layerPar  = [col0, '   ',  col1,    '   ',  col2,  '   ', ...
        col3, '   ', col4,    '   ',  col5, '   ',...
        col6, '   ', col7];
    
    modelParams{mLine+1} = layerPar;
    
    mLine = mLine + 1;
    
end

modelTable = cell2table(modelParams');

writetable(modelTable,modelFile, 'WriteVariableNames', false);

end
