function plot_correlation(eye_movement_corr, threshold, ses, trial, name)
% plot correlation of eye movement with the independent components
% input: eye_movement_corr 2*64 matrix, 1st row: horizontal eye movement corr., 2nd row: vertical eye movement corr.

ncomponents = size(eye_movement_corr,2);

comp = linspace(1,ncomponents,ncomponents);

figure('visible', 'off');
set(gcf,'units','points','position',[100,100,700,500]);

plot(comp, zscore(eye_movement_corr(1,:)), '-ro', 'LineWidth',2);
hold on;
plot(comp, zscore(eye_movement_corr(2,:)), '-bo', 'LineWidth',2);
hold on;
plot([1,ncomponents],[threshold,threshold],'k--');
hold on;
plot([1,ncomponents],[-1*threshold,-1*threshold],'k--');
xlabel(sprintf('%i independent components',ncomponents));
xlim([1,ncomponents]);
ylabel('corr. with eye movement (zscore + scalar product)')
title(sprintf('%s: Artefact removal (eye movement) session:%i, trial:%i',name, ses, trial))
legend('horizontal', 'vertical');
set(gca,'fontsize',15);

fName = sprintf('pictures/corr/s%i_%s_t%i_ICA_corr.png', ses, name, trial);
saveas(gcf, fName);

end