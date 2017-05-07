% main file for BCI project #ames !
% last update: 30/04

clc;
close all;
clear all;

%% load in data from .bdf - uncomment this for the 1st time!
%fName = '/home/bandi/EPFL/BCI/ag2_22032017.bdf'; % Andras' 1st
%[header, channels, eye_channels, biceps_channels, cleared_trigger] = initialize(fName);
%saveName = '/home/bandi/EPFL/BCI/Andras_1.mat';
%trials = save_to_mat(header, channels, eye_channels, biceps_channels, cleared_trigger, saveName);

%% load in data from saved .mat file (struct of structs)
fName = '/home/bandi/EPFL/BCI/Andras_1.mat';
trials = load(fName);