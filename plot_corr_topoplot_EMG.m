function plot_corr_topoplot_EMG(EMG_corr, eeglab_path, ses, trial, name)
% plots ICA-eye_movement correlation projected to the scalp
% input: eye_movement_corr 2*64 matrix, 1st row: horizontal eye movement corr., 2nd row: vertical eye movement corr.

addpath(sprintf('%s/functions/sigprocfunc',eeglab_path),...   
        sprintf('%s/functions/guifunc',eeglab_path),...  
        sprintf('%s/functions/adminfunc',eeglab_path));
    
figure('visible', 'off');
set(gcf,'units','points','position',[100,100,1000,500]);
subplot(1,2,1);
topoplot(zscore(EMG_corr(1,:))', 'eeglab_chan64_2.elp');
title(sprintf('%s: biceps corr. session:%i, trial:%i',name, ses, trial));

subplot(1,2,2);
topoplot(zscore(EMG_corr(2,:))', 'eeglab_chan64_2.elp');
title(sprintf('%s: triceps corr. session:%i, trial:%i',name, ses, trial));

fName = sprintf('pictures/corr/s%i_%s_t%i_ICA_corr_top.png',ses, name, trial);
saveas(gcf, fName); 

end