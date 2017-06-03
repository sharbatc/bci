function [horizontal_corr, vertical_corr] = check_correlation(ICAcomponents, eye_channels, down, threshold, eeglab_path, trial, name)
% checks the correlation of the channels with EOG  (zscore + scalar product)

filtered_EOG = filter_EOG(eye_channels, down);

% reject the beginning and the end of the trial (it's noisy after temporal filtering)
rej = floor(0.05*size(filtered_EOG(1,:),2));  % 5% of the dataset (in the beg. and end.)
horizontal_eye_movement = zscore(filtered_EOG(1,rej:end-rej));
vertical_eye_movement = zscore(filtered_EOG(2,rej:end-rej));

ncomponents = size(ICAcomponents,1);

eye_movement_corr = zeros(2,ncomponents);  % to store results
for i=1:ncomponents
    chan = zscore(ICAcomponents(i,rej:end-rej));
    eye_movement_corr(1,i) = chan * horizontal_eye_movement';
    eye_movement_corr(2,i) = chan * vertical_eye_movement';    
end

plot_correlation(eye_movement_corr, threshold, trial, name);
if ncomponents == 64
    plot_corr_topoplot(eye_movement_corr, eeglab_path, trial, name);
end

% check for high correlation
horizontal_corr = find(abs(zscore(eye_movement_corr(1,:))) > threshold);
vertical_corr = find(abs(zscore(eye_movement_corr(2,:))) > threshold);


end