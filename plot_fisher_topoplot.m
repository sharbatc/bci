function plot_fisher_topoplot(labels, features, disc, eeglab_path, ses, name)
% plots integral (easy & hard) of the whole power and fisher score, projected to the scalp

addpath(sprintf('%s/functions/sigprocfunc',eeglab_path),...
        sprintf('%s/functions/guifunc',eeglab_path),...
        sprintf('%s/functions/adminfunc',eeglab_path));

% get out power from feature matrix
band_powers = features(:,end-(64*7)+1:end); % get the corresponding values from the row vector
% initialize arrays to store values for every channels
power_easy = [];
power_hard = [];
% iterate over epochs and get the integral of the whole PSD for every electrodes
for i=1:size(labels)
    band_powers_m = reshape(band_powers(i,:),7,64)'; % get back the matrix form, for 1 single epoch
    power = band_powers_m(:,1); % get the intergal of the whole PSD
    if labels(i) == 0
        power_easy = [power_easy, power];
    elseif labels(i) == 1
        power_hard = [power_hard, power];
    end 
end
power_easy = mean(power_easy,2);
power_hard = mean(power_hard,2);

% get out power from Fisher scores
fisher_power = disc(:,end-6); % get the Fisher score of the integral
fisher_power = fisher_power - mean(fisher_power);

figure;
topoplot((power_easy-mean(power_easy)), 'eeglab_chan64_2.elp');
%topoplot(power_easy, 'eeglab_chan64_2.elp');
title(sprintf('%s: power - easy trials, session:%i',name,ses));
set(gca,'fontsize',15);
fName = sprintf('pictures/s%i_%s_power_easy.png',ses,name);
saveas(gcf, fName);

figure;
topoplot((power_hard-mean(power_hard)), 'eeglab_chan64_2.elp');
%topoplot(power_hard, 'eeglab_chan64_2.elp');
title(sprintf('%s: power - hard trials, session:%i',name,ses));
set(gca,'fontsize',15);
fName = sprintf('pictures/s%i_%s_power_hard.png',ses,name);
saveas(gcf, fName);

figure;
topoplot(fisher_power, 'eeglab_chan64_2.elp');
title(sprintf('%s: Fisher score of power, session:%i',name,ses));
set(gca,'fontsize',15);
fName = sprintf('pictures/s%i_%s_power2.png',ses,name);
saveas(gcf, fName);

end
