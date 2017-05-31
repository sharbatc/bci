function plot_fisher_topoplot(labels, features, eeglab_path, name)
% plots integral of the whole power, projected to the scalp

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


figure;
set(gcf,'units','points','position',[100,100,1300,500]);
subplot(1,3,1);
topoplot(power_easy-mean(power_easy), 'eeglab_chan64_2.elp');
title('easy trials');
subplot(1,3,2);
topoplot((power_easy-power_hard-mean(power_easy-power_hard)), 'eeglab_chan64_2.elp');
title(sprintf('%s: power - discr. chans', name));  % not Fisher score! (just the difference of the 2 prev plots)
subplot(1,3,3);
topoplot(power_hard-mean(power_hard), 'eeglab_chan64_2.elp');
title('hard trials');
fName = sprintf('pictures/%s_power.png',name);
saveas(gcf, fName);

%figure;
%topoplot((power_easy-power_hard-mean(power_easy-power_hard)), 'eeglab_chan64_2.elp');
%title(sprintf('%s: power - discr. chans', name));  % not Fisher score! (just the difference of the 2 prev plots)
%fName = sprintf('pictures/%s_power.png',name);
%saveas(gcf, fName);

end