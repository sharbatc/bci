function plot_correlation(eye_movement_corr, threshold, trial, name)
% plot correlation of eye movement with the independent components
% input: eye_movement_corr 2*64 matrix, 1st row: horizontal eye movement corr., 2nd row: vertical eye movement corr.

comp = linspace(1,64,64);

figure('visible', 'off');
plot(comp, zscore(eye_movement_corr(1,:)), '-ro', 'LineWidth',2);
hold on;
plot(comp, zscore(eye_movement_corr(2,:)), '-bo', 'LineWidth',2);
hold on;
plot([1,64],[threshold,threshold],'k--');
hold on;
plot([1,64],[-1*threshold,-1*threshold],'k--');
xlabel('independent components');
xlim([1,64]);
ylabel('corr. with eye movement (zscore + scalar product)')
title(sprintf('%s: Artefact removal (eye movement) trial:%i',name, trial))
legend('horizontal', 'vertical');

fName = sprintf('pictures/corr/%s_t%i_ICA_corr.png',name, trial);
saveas(gcf, fName);

end