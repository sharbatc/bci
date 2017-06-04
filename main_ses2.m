%% Load the data
clc;
clear;
close all;

mac = 1;

name = 'Mariana';
fName = '/Users/sharbatc/Academia/Projects/BCI/data/ad10_03042017.bdf';
labels = [1,2,0,2,1,2,1,1,1,0,0,2,0,0,2];

Fs = 2048;

%% load in data from .bdf - use this for the 1st time!
[header, channels, eye_channels, biceps_channels, cleared_trigger_ses2] = initialize_ses2(fName);
saveName = sprintf('%s_2.mat',name);
data = save_to_mat(header, labels, channels, eye_channels, biceps_channels, cleared_trigger_ses2, saveName);
fprintf('data for ses2 initialized and saved to .mat file!\n')

