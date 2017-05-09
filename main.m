% main file for BCI project #ames !
% last update: 30/04

clc;
close all;
clear all;

%% load in data from .bdf - uncomment this for the 1st time!
%fName = '/home/bandi/EPFL/BCI/ag2_22032017.bdf'; % Andras' 1st
%[header, channels, eye_channels, biceps_channels, cleared_trigger] = initialize(fName);
%saveName = '/home/bandi/EPFL/BCI/Andras_1.mat';
%data = save_to_mat(header, channels, eye_channels, biceps_channels, cleared_trigger, saveName);

%% load in data from saved .mat file (struct of structs)
fName = '/home/bandi/EPFL/BCI/Andras_1.mat';
load(fName);
Fs = 2048;
fprintf('data loaded!\n')

% description of the data format:
% struct (called data) with the original header and 15 structs inside (for each trials).
% trials have 4 matrices, channels, eye_channels, biceps_channels and cleared_trigger (access like: data.t1.channels)
% feel free to extend with more fields! (data.* = )

%% downsample EEG channels
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
for i=1:15
   data.(trials{i}).channels = data.(trials{i}).channels(:,1:8:end);
end
Fs = 2048/8;
fprintf('EEG downsampled by 8!\n')

%% plot signal before filtering (1st trial 1st channel)
[pxx_tmp, f_tmp] = calc_PSD(data.t1.channels, Fs);  % calc PSD for the 1st trial just to see how it looks like
plot_single_channel(data.t1.channels(1,:), f_tmp, pxx_tmp(1,:), Fs)

%% spatial filtering
% always do spatial filtering first!
for i=1:15
   data.(trials{i}).channels = spatial_filer(data.(trials{i}).channels);
end
fprintf('spatial filtering done!\n')

%% check correlation (with eye movement)
corr_threshold = 0.8;
trial_thershold = 10;
discard_channels = zeros(1,64);
for i=1:15
    [horizontal_corr, vertical_corr] = check_correlation(data.(trials{i}).channels,...
                                                         data.(trials{i}).eye_channels, corr_threshold);
    discard_channels_trial = [horizontal_corr, vertical_corr];  % channels discarded according to this trial
    discard_channels(discard_channels_trial) = discard_channels(discard_channels_trial)+1; % no += 1 :(
end
% channels wich have high(er than 'corr_threshold') correlation in (at least) 'trial_threshold' trials
discard = find(discard_channels > trial_thershold);
fprintf('%i channels discarded from analysis, because of high correlation!\n',size(discard,2));


%% temporal filtering (this takes some time...)
for i=1:15
   data.(trials{i}).channels = temporal_filter(data.(trials{i}).channels,Fs);
end
fprintf('temporal filtering done!\n')

%% calc PSD
for i=1:15
   [data.(trials{i}).pxx, data.(trials{i}).f] = calc_PSD(data.(trials{i}).channels,Fs);
end
fprintf('PSD calculated!\n')

%% plot filtered signal (1st trial 1st channel)
plot_single_channel(data.t1.channels(1,:), data.t1.f,...
                    data.t1.pxx(1,:), Fs)


% ===================================== #TODO =====================================
%% PCA (just for transforming the feutures, no dim. reduction)
for i=1:15
    data.(trials{i}).bestindex = apply_pca(data.(trials{i}).power_spectrum);  % double check this!
end

%% feature selection
% features are the PSDs of the channels (data.t*.pxx)
% eg. see Data Analysis class codes

%% classify
% ... yup ...

