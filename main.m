% main file for BCI project #ames !
% last update: 30/04

clc;
close all;
clear all;

% load in data
fName = '/home/bandi/EPFL/BCI/ag2_22032017.bdf'; % Andras' 1st
%fName = '/home/bandi/EPFL/BCI/ad3_08032017.bdf'; % Sharbat's 1st
[header, channels, eye_channels, biceps_channels, trigger] = initialize(fName);

trial = 1;  % select trial 1:
[channels_, eye_channels_, biceps_channels_, trigger_] = slice_trial(trial, channels, eye_channels, biceps_channels, trigger);