function [biceps_corr, triceps_corr] = check_correlation_EMG(ICAcomponents, filtered_EMG, Fs, down_, threshold, eeglab_path, ses, trial, name)
% checks the correlation of the channels with EMG  

%Downsampling
filtered_EMG = filtered_EMG(:,1:down_:end);
%Filtering
filtered_EMG = temporal_filter(filtered_EMG, Fs);
filtered_EMG =[ filtered_EMG(1,:) - filtered_EMG(2,:); filtered_EMG(3,:) - filtered_EMG(4,:)];


% reject the beginning and the end of the trial (it's noisy after temporal filtering)
rej = floor(0.05*size(filtered_EMG(1,:),2));  % 5% of the dataset (in the beg. and end.)
biceps = zscore(filtered_EMG(1,rej:end-rej));
triceps = zscore(filtered_EMG(2,rej:end-rej));

ncomponents = size(ICAcomponents,1);

EMG_corr = zeros(2,ncomponents);  % to store results
for i=1:ncomponents
    chan = zscore(ICAcomponents(i,rej:end-rej));
    EMG_corr(1,i) = chan * biceps';
    EMG_corr(2,i) = chan * triceps';    
end

plot_correlation_EMG(EMG_corr, threshold, ses, trial, name);
if ncomponents == 64
    plot_corr_topoplot_EMG(EMG_corr, eeglab_path, ses, trial, name);
end

% check for high correlation
biceps_corr = find(abs(zscore(EMG_corr(1,:))) > threshold);
triceps_corr = find(abs(zscore(EMG_corr(2,:))) > threshold);


end