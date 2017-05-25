function plot_fisher_topoplot(labels, features, eeglab_path, name)

addpath(sprintf('%s/functions/sigprocfunc',eeglab_path),...   
        sprintf('%s/functions/guifunc',eeglab_path),...  
        sprintf('%s/functions/adminfunc',eeglab_path));   

% get out PSD values from feature matrix
pxx = features(:,1:end-(64*7));
% get out power from feature matrix
band_powers = features(:,end-(64*7)+1:end); % get the corresponding values from the row vector

% initialize arrays to store values for every channels
low_freq_easy = [];
low_freq_hard = [];
power_easy = [];
power_hard = [];
% iterate over epochs and get 0-1Hz PSD and the integral of the whole PSD for every electrodes
for i=1:size(labels)
    pxx_m = reshape(pxx(i,:),[],64)'; % get back the matrix form, for 1 single epoch
    low_freq = pxx_m(:,1); % get the 0-1Hz values
    band_powers_m = reshape(band_powers(i,:),7,64)'; % get back the matrix form, for 1 single epoch
    power = band_powers_m(:,1); % get the intergal of the whole PSD
    if labels(i) == 0
        low_freq_easy = [low_freq_easy, low_freq];
        power_easy = [power_easy, power];
    elseif labels(i) == 1
        low_freq_hard = [low_freq_hard, low_freq];
        power_hard = [power_hard, power];
    end
    
end

low_freq_easy = mean(low_freq_easy,2);
low_freq_hard = mean(low_freq_hard,2);
power_easy = mean(power_easy,2);
power_hard = mean(power_hard,2);

figure;
topoplot(low_freq_easy-mean(low_freq_easy), 'eeglab_chan64_2.elp');
title(sprintf('%s 0-1 Hz - easy trials', name));
fName = sprintf('pictures/%s_low_freq_easy.png',name);
saveas(gcf, fName);

figure;
topoplot(low_freq_hard-mean(low_freq_hard), 'eeglab_chan64_2.elp');
title(sprintf('%s 0-1 Hz - hard trials', name));
fName = sprintf('pictures/%s_low_freq_hard.png',name);
saveas(gcf, fName);

figure;
topoplot((low_freq_easy-low_freq_hard-mean(low_freq_easy-low_freq_hard)), 'eeglab_chan64_2.elp');
title(sprintf('%s 0-1 Hz - discr. chans', name));
fName = sprintf('pictures/%s_low_freq.png',name);
saveas(gcf, fName);

figure;
topoplot(power_easy-mean(power_easy), 'eeglab_chan64_2.elp');
title(sprintf('%s power - easy trials', name));
fName = sprintf('pictures/%s_power_easy.png',name);
saveas(gcf, fName);

figure;
topoplot(power_hard-mean(power_hard), 'eeglab_chan64_2.elp');
title(sprintf('%s power - hard trials', name));
fName = sprintf('pictures/%s_power_hard.png',name);
saveas(gcf, fName);

figure;
topoplot((power_easy-power_hard-mean(power_easy-power_hard)), 'eeglab_chan64_2.elp');
title(sprintf('%s power - discr. chans', name));
fName = sprintf('pictures/%s_power.png',name);
saveas(gcf, fName);

end