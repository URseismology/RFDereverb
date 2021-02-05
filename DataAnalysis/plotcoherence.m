clear coher*
% make plot for station average ZR coherence

network = 'ZA';
station = {'B13','B15'};
station = string(station);

c = 7;
r = ceil(length(station)/c);

color = ['k';'b';'r'];

hhh = figure(41);

set(gcf,'Position',[100,100,1500,1500]);
clf;

ha = tight_subplot(r,c,[.02 .01],[.05 .05],[.05 .05]);

for is = 1:length(station)
    
    staname = station(is);
    %     dispname = dispsta(is);
    
    fprintf('Doing station %s\n',staname);
    
    %     [ff,coherZR] = coherSYNcompute(staname,localBaseDir);
    [ff,coherZR,coherZP]  = cohercompute(network,staname,localBaseDir,1);
    [~,coherZRN,coherZPN] = cohercompute(network,staname,localBaseDir,2);
    
    axes(ha(is)); % subplot
    
    set(gca,'XScale','log','YScale','linear');
    set(gca,'LineWidth',1);
    hold on;
    
    plot(ff,coherZR,'r-','linewi',1); hold on;
    pn = plot(ff,coherZRN,'r-'); pn.Color(4) = 0.4; hold on;
    %         plot(ff,coherZP,'b-','linewi',1); hold on;
    %         pn = plot(ff,coherZPN,'b-'); pn.Color(4) = 0.4; hold on;
    %         xlim([0 6]);
    
    
    xlim([1.01e-2 2]);
    ylim([0 1]);
    grid on;
    hold on;
    
%     % legend on the first plot
%     if is == 1
%         
%         %             % xlim 0 - 6, linear
%         %             rectangle('position',[4.7 0.8 1.25 0.15],'FaceColor',[1 1 1],'EdgeColor',[0 0 0]);
%         %             hold on;
%         %             plot([4.8 5.1],[0.84 0.84],'r-','linewi',1); hold on; text(5.5,0.84,'ZR','FontSize',12);
%         %             pn = plot([5.1 5.4],[0.84 0.84],'r-','linewi',1); pn.Color(4) = 0.4;  hold on;
%         %             plot([4.8 5.1],[0.91 0.91],'b-','linewi',1); hold on; text(5.5,0.91,'ZP','FontSize',12);
%         %             pn = plot([5.1 5.4],[0.91 0.91],'b-','linewi',1); pn.Color(4) = 0.4;  hold on;
%         
%         % xlim 0 - 2, log
%         rectangle('position',[0.5 0.8 1 0.15],'FaceColor',[1 1 1],'EdgeColor',[0 0 0]);
%         hold on;
%         plot([0.55 0.70],[0.88 0.88],'r-','linewi',1); hold on; text(0.95,0.88,'ZR','FontSize',11);
%         hr = plot([0.70 0.85],[0.88 0.88],'r-','linewi',1); hr.Color(4) = 0.4; hold on;
%         %             plot([0.6 0.75],[0.91 0.91],'b-','linewi',1); hold on; text(1.0,0.91,'ZP','FontSize',12);
%         %             hb = plot([0.75 0.9],[0.91 0.91],'b-','linewi',1); hb.Color(4) = 0.4; hold on;
%     end
    
    if is > (r-1)*c
        xlabel('Frequency, Hz','fontsize',12);
        xticks([0.1 1]);
        xticklabels({'0.1','1'});
        set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',12);
    else
        xticks([0.1 1]);
    end
    
    for ir = 1:r
        if is == 1 + (ir-1)*c
            ylabel('Coherence','fontsize',12);
            yticks([0 0.2 0.4 0.6 0.8 1.0]);
            yticklabels({'0','0.2','0.4','0.6','0.8','1'});
            set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',12);
        else
            yticks([0 0.2 0.4 0.6 0.8 1.0]);
        end
    end
    
    title(sprintf('%s H_w=%4d m',char(staname),Hw * 1000),'FontSize',12);
    
end

% coherZRS_sed = mean(coherZRS_sed);
% coherZPS_sed = mean(coherZPS_sed);
% coherZRN_sed = mean(coherZRN_sed);
% coherZPN_sed = mean(coherZPN_sed);
%
%
% for is = 1:length(stationall)
%
%     staname = stationall(is);
%
%     fprintf('Doing station %s\n',staname);
%
%     [ff,coherZRS(is,:),coherZPS(is,:)] = cohercompute(staname,localBaseDir,1);
%     [~,coherZRN(is,:),coherZPN(is,:)] = cohercompute(staname,localBaseDir,2);
%
% end
%
% coherZRS_all = mean(coherZRS);
% coherZPS_all = mean(coherZPS);
% coherZRN_all = mean(coherZRN);
% coherZPN_all = mean(coherZPN);
%
% h20 = figure(20); clf;
% set(gca,'XScale','log','YScale','linear');
% set(gca,'LineWidth',1);
% hold on;
%
% % plot(ff,coherZRS_all,'r-','linewi',1); hold on;
% % pn = plot(ff,coherZRN_all,'r-'); pn.Color(4) = 0.4; hold on;
% % plot(ff,coherZPS_all,'b-','linewi',1); hold on;
% % pn = plot(ff,coherZPN_all,'b-'); pn.Color(4) = 0.4; hold on;
% % xlim([1.01e-2 2]);
% % ylim([0 1]);
% % grid on;
%
% plot(ff,coherZRS_sed,'r-','linewi',1.5); hold on;
% plot(ff,coherZRS_all,'k-','linewi',1); hold on;
% xlim([1.01e-2 2]);
% ylim([0 1]);
% grid on;
%
% vs = 0.27;
% Hs = 0.25;
% for in = 1:5
%     xline((2 * in - 1) * vs / (4 * Hs),'b--'); hold on;
% end
%
% % rectangle('position',[0.5 0.8 1 0.15],'FaceColor',[1 1 1],'EdgeColor',[0 0 0]);
% % hold on;
% % plot([0.6 0.75],[0.84 0.84],'r-','linewi',1); hold on; text(1.0,0.84,'ZR','FontSize',12);
% % hr = plot([0.75 0.9],[0.84 0.84],'r-','linewi',1); hr.Color(4) = 0.4; hold on;
% % plot([0.6 0.75],[0.91 0.91],'b-','linewi',1); hold on; text(1.0,0.91,'ZP','FontSize',12);
% % hb = plot([0.75 0.9],[0.91 0.91],'b-','linewi',1); hb.Color(4) = 0.4; hold on;
%
% xlabel('Frequency, Hz','fontsize',18);
% set(gca,'XTickLabel',cellstr(num2str(get(gca,'XTick')')),'fontsize',18);
%
% ylabel('Coherence','fontsize',18);
% ytick([0 0.2 0.4 0.6 0.8 1]);
% set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',18);


saveFig('Fig_ZRCoherence_water.pdf','Your Directory',1,hhh);
