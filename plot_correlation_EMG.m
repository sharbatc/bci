function plot_correlation_EMG(EMG_corr, threshold, ses, trial, name)

ncomponents = size(EMG_corr,2);

comp = linspace(1,ncomponents,ncomponents);

figure('visible', 'off');
set(gcf,'units','points','position',[100,100,700,500]);

plot(comp, zscore(EMG_corr(1,:)), '-ro', 'LineWidth',2);
hold on;
plot(comp, zscore(EMG_corr(2,:)), '-bo', 'LineWidth',2);
hold on;
plot([1,ncomponents],[threshold,threshold],'k--');
hold on;
plot([1,ncomponents],[-1*threshold,-1*threshold],'k--');
xlabel(sprintf('%i independent components',ncomponents));
xlim([1,ncomponents]);
ylabel('corr. with biceps activation (zscore + scalar product)')
title(sprintf('%s: Artefact removal (biceps activation) session:%i, trial:%i',name, ses, trial))
legend('biceps', 'triceps');
legend boxoff;
set(gca,'fontsize',15,'box','off','TickDir','out','TickLength',[.02 .02],...
	'XMinorTick','on','YMinorTick','on','XColor',[.3 .3 .3],'YColor',[.3 .3 .3]);

fName = sprintf('pictures/corr/s%i_%s_t%i_ICA_corr.png', ses, name, trial);
saveas(gcf, fName);

end