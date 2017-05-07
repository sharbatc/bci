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
fprintf('data loaded!')

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
