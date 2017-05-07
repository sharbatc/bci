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
load('Andras_1.mat');
fprintf('data loaded!')

% description of the data:
%%% struct file named data with one matrix (header - raw data) 15 struct files inside (15 trials). Each
% trial has 4 matrices, channels, eye_channels, biceps_channels,
% cleared_trigger, and we can add more to them

%% check correlation
clc;
corr_threshold = 0.8;
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
discard_channels = zeros(1,64);
for i=1:15
    [horizontal_corr, vertical_corr] = check_correlation(data.(trials{i}).channels,...
                                                         data.(trials{i}).eye_channels, corr_threshold);
    discard_channels_trial = [horizontal_corr, vertical_corr];  % channels discarded according to this trial
    discard_channels(discard_channels_trial) = discard_channels(discard_channels_trial)+1; % no += 1 :(
end
% channels wich have high(er than threshold) correlation in (at least) half of the trials
discard = find(discard_channels > 7)  


%% filter each channel
fprintf('Begin filtering...')

trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'};

for i=1:15
    data.(trials{i}).filtered_channels = filterChannels(data.(trials{i}).channels);
end
% we should also filter EOG and EMG

fprintf('Filtering done!')
 
%% organizing the power plots into matrices (64 channels as rows)

for i=1:15
    data.(trials{i}).power_spectrum = powerSpect(data.(trials{i}).filtered_channels);
end

% defining the frequency range
S = size(data.t1.channels);
L = S(2);
Fs = 2048;
f = Fs*(0:(L/2))/L;

%% plot just as an example
fourier_before=periodogram(data.t1.channels(48,:));
fourier_after=data.t1.power_spectrum(48,:);
figure;
subplot(1,2,1)
plot(f,log(fourier_before(1:size(f,2),1)));
%xlim([0,70])
subplot(1,2,2)
plot(f,log(fourier_after(1,1:size(f,2))));
%xlim([0,70])

%%
figure
plot(data.t1.channels(48,:))

%%% MISSING
%% do pca

for i=1:15
    data.(trials{i}).bestindex = apply_pca(data.(trials{i}).power_spectrum);
end

%% select best features

%% classify

