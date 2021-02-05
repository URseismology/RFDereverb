% make plot of psd for station average
clear s2*

% station = ['B01';'B02';'B04';'B05';'B06';'B08';'B11';'B13';'B16';'B17';...
%     'B19';'B22';'B23';'B24';'B25';'B26'];

station = {'B13','B15'};
station = string(station);

c = 3;
r = ceil(length(station)/c);

cmp = ['Z'];
% cmp = ['Z';'R';'T'];
color = ['k';'b';'r'];

% h = figure(5);
% 
% set(gcf,'Position',[100,100,1500,500]);
% clf;
% 
% ha = tight_subplot(r,c,[.02 .01],[.1 .1],[.1 .1]);

for is = 1:length(station)
    
    staname = station(is);
%     dispname = dispsta(is);
    
    fprintf('Doing station %s\n',staname);
    
%     axes(ha(is));
%     set(gca,'XScale','log','YScale','log');
%     set(gca,'LineWidth',1);
%     hold on;
    
    for ic = 1:length(cmp)
        
        fprintf('   Component %s\n',cmp(ic));
        
        [f,Nf,s2noiMean,s2sigMean] = ...
            psdcompute(localBaseDir,staname,cmp(ic),2);
        
        switch ic
            case 1
                s2noiallZ(is,:) = s2noiMean;
                s2sigallZ(is,:) = s2sigMean;
                
            case 2
                s2noiallR(is,:) = s2noiMean;
                s2sigallR(is,:) = s2sigMean;
                
            case 3
                s2noiallT(is,:) = s2noiMean;
                s2sigallT(is,:) = s2sigMean;
                
        end
        
%         pn = loglog(f(2:Nf),s2noiMean(2:Nf),'-','Color',color(ic));
%         pn.Color(4) = 0.4;
%         hold on;
        
%         ps = loglog(f(2:Nf),s2sigMean(2:Nf),'-','Color',color(ic),...
%             'DisplayName',cmp(ic),'linewi',1);
%         hold on;
%         
%         xlim([1.01e-2 2]);
%         ylim([1e0 1e6]); % 4 - 12
%         grid on;
        
    end
    
    % legend on the first plot
%     if is == 1
%         rectangle('position',[0.5 10^(4.8) 1 10^(5.6)],'FaceColor',[1 1 1],'EdgeColor',[0 0 0]);
%         hold on;
% %         plot([0.6 0.75],[10^(6.3) 10^(6.3)],'r-','linewi',1); hold on; text(1.0,10^(6.3),'T','FontSize',12);
% %         hr = plot([0.75 0.9],[10^(6.3) 10^(6.3)],'r-','linewi',1); hr.Color(4) = 0.4; hold on;
%         plot([0.6 0.9],[10^5 10^5],'b-','linewi',1); hold on; text(1.0,10^5,'R','FontSize',12);
% %         hb = plot([0.75 0.9],[10^(6.8) 10^(6.8)],'b-','linewi',1); hb.Color(4) = 0.4; hold on;
%         plot([0.6 0.9],[10^(5.4) 10^(5.4)],'k-','linewi',1); hold on; text(1.0,10^(5.4),'Z','FontSize',12);
% %         hk = plot([0.75 0.9],[10^(7.3) 10^(7.3)],'k-','linewi',1); hk.Color(4) = 0.4; hold on;
%     end
%     
%     if is > (r-1)*c
%         xlabel('Frequency, Hz','fontsize',18);
%         set(gca,'XTickLabel',cellstr(num2str(get(gca,'XTick')')),'fontsize',15);
%     end
%     
%     for ir = 1:r
%         if is == 1 + (ir-1)*c
%             ylabel('Amplitude, log(Counts)','fontsize',18);
%             yticks([1e0 1e2 1e4 1e6]);
%             yticklabels({'0','2','4','6'});
%             set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',15);
%         else
%             yticks([1e0 1e2 1e4 1e6]);
%         end
%     end
%     
%         title(sprintf('Synthetic: %s',char(dispname)));
%     text(10^((log10(1.01e-2)+log10(2))/2),10^(11.5),strcat(char(staname)),...
%         'HorizontalAlignment','center','FontSize',18,'FontWeight','bold');
%     
%     hold on;
    
end

Znoi = mean(s2noiallZ);
% Rnoi = mean(s2noiallR);
% Tnoi = mean(s2noiallT);
Zsig = mean(s2sigallZ);
% Rsig = mean(s2sigallR);
% Tsig = mean(s2sigallT);

h20 = figure(20); clf;

loglog(f(2:Nf),Zsig(2:Nf),'-','Color',color(1),'linewi',1); hold on;
% loglog(f(2:Nf),Rsig(2:Nf),'-','Color',color(2),'linewi',1); hold on;
% loglog(f(2:Nf),Tsig(2:Nf),'-','Color',color(3),'linewi',1); hold on;
pn = loglog(f(2:Nf),Znoi(2:Nf),'-','Color',color(1)); pn.Color(4) = 0.4; hold on;
% pn = loglog(f(2:Nf),Rnoi(2:Nf),'-','Color',color(2)); pn.Color(4) = 0.4; hold on;
% pn = loglog(f(2:Nf),Tnoi(2:Nf),'-','Color',color(3)); pn.Color(4) = 0.4; hold on;
xlim([1.01e-2 2]);
ylim([1e4 1e12]);
grid on;

% vs = 0.26;
% Hs = 0.25;
% for in = 1:5
%     xline((2 * in - 1) * vs / (4 * Hs),'b--'); hold on;
% end

% rr = rectangle('position',[0.5 1e10 0.8 10^(11.6)],'FaceColor',[1 1 1],'EdgeColor',[0 0 0]);
% hold on;
% plot([0.6 0.75],[10^(10.3) 10^(10.3)],'r-','linewi',1); hold on; text(1.0,10^(10.3),'T','FontSize',12);
% hr = plot([0.75 0.9],[10^(10.3) 10^(10.3)],'r-','linewi',1); hr.Color(4) = 0.4; hold on;
% plot([0.6 0.75],[10^(10.8) 10^(10.8)],'b-','linewi',1); hold on; text(1.0,10^(10.8),'R','FontSize',12);
% hb = plot([0.75 0.9],[10^(10.8) 10^(10.8)],'b-','linewi',1); hb.Color(4) = 0.4; hold on;
% plot([0.6 0.75],[10^(11.3) 10^(11.3)],'k-','linewi',1); hold on; text(1.0,10^(11.3),'Z','FontSize',12);
% hk = plot([0.75 0.9],[10^(11.3) 10^(11.3)],'k-','linewi',1); hk.Color(4) = 0.4; hold on;
xlabel('Frequency, Hz','fontsize',18);
set(gca,'XTickLabel',cellstr(num2str(get(gca,'XTick')')),'fontsize',15);
text(10^((log10(1.01e-2)+log10(2))/2),10^(11.5),'All',...
    'HorizontalAlignment','center','FontSize',18,'FontWeight','bold');
ylabel('Amplitude, log(Counts)','fontsize',18);
yticks([1e4 1e6 1e8 1e10 1e12]);
yticklabels({'4','6','8','10','12'});
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',15);


% saveFig('Fig_PSD_Syn.pdf','Your Directory',1,ha);
