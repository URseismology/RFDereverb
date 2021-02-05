function [] =  saveFig(fName, saveDir, usePDF, figHandle)

% Inputs
% compMaps = figure('units', 'normalized', 'Position',[0 0 1 1], ...
% 'DefaultAxesFontSize', 18);
        
        if usePDF
            saveFile = [saveDir  fName];
            set(figHandle,'Units','Inches');
            pos = get(figHandle,'Position');
            set(figHandle,'PaperPositionMode','Auto','PaperUnits','Inches', ...
                'PaperSize',[pos(3), pos(4)])
            print(figHandle,saveFile,'-dpdf','-r0')
            %print(figHandle,saveFile,'-deps','-r0')
        else
            
            saveFile = [saveDir  fName];
            set(gcf,'PaperPositionMode','auto')
            print(saveFile,'-dpng','-r0')
        end
        
end