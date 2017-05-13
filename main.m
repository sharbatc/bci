% main file for BCI project #ames !
% last update: 10/05 - Andras


%% load in data from .bdf - use this for the 1st time!
clc;
clear;
close all;

mac = 0; % flag for ICA -> change this to 1 on mac!

% labels are hard coded...
name = 'Elisabetta';
fName = '/home/bandi/EPFL/BCI/ag1_22032017.bdf'; % Elisabetta's 1st
labels = [0,1,2,0,2,0,1,1,2,2,1,0,0,2,1]; % Elisabetta's 1st
%name = 'Mariana';
%fName = '/home/bandi/EPFL/BCI/ad10_13032017.bdf'; % Mariana's 1st
%labels = [0,2,0,0,2,0,2,2,1,1,1,1,2,1,0]; % Mariana's 1st
%name = 'Sharbat';
%fName = '/home/bandi/EPFL/BCI/ad3_08032017.bdf'; % Sharbat's 1st
%labels = [0,0,0,1,1,2,2,2,0,0,1,2,1,1,2]; % Sharbat's 1st
%name = 'Andras';
%fName = '/home/bandi/EPFL/BCI/ag2_22032017.bdf'; % Andras' 1st
%labels = [0,2,0,1,2,2,0,0,0,1,1,1,2,2,1]; % Andras' 1st

[header, channels, eye_channels, biceps_channels, cleared_trigger] = initialize(fName);
saveName = sprintf('/home/bandi/EPFL/BCI/%s_1.mat',name);
data = save_to_mat(header, labels, channels, eye_channels, biceps_channels, cleared_trigger, saveName);
Fs = 2048;
fprintf('data initialized and saved to .mat file!\n')


%% load in data from saved .mat file (struct of structs)
clc;
clear;
close all;

mac = 0; % flag for ICA -> change this to 1 on mac!

name = 'Elisabetta';
fName = sprintf('%s_1.mat',name);
load(fName);
Fs = 2048;
fprintf('data loaded!\n')

% description of the data format:
% struct (called data) with the original header, labels and 15 structs inside (for each trials).
% trials have 4 matrices, channels, eye_channels, biceps_channels and cleared_trigger (access like: data.t1.channels)
% feel free to extend with more fields! (data.* = )


%% downsample EEG channels
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
down_ = 8; %-> new Fs = 256 Hz
for i=1:15
   data.(trials{i}).channels = data.(trials{i}).channels(:,1:down_:end);
end
Fs = Fs/down_;
fprintf('EEG downsampled by %i!\n',down_)


%% spatial filtering
% always do spatial filtering first!
for i=1:15
   data.(trials{i}).channels = spatial_filer(data.(trials{i}).channels);
end
fprintf('spatial filtering done!\n')


%% apply ICA  (first start eeglab from matlab consol...)
% it's pretty slow and prints a lot!
for i=1:15
   % calculate weight matrix
   [data.(trials{i}).weights, data.(trials{i}).sphere] = ICA(data.(trials{i}).channels, mac);
   % project dataset
   data.(trials{i}).channels = data.(trials{i}).weights * data.(trials{i}).channels;
end
if mac == 0 % delete generated (random) binary files on linux
    delete 'binica*'
    delete 'bias_after_adjust'
end
fprintf('ICA done!\n')


%% check correlation (with eye movement)
% one can run from this after spatial filtering (and just skip the ICA part)
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
corr_threshold = 0.8;
trial_thershold = 8;
discard_channels = zeros(1,64);
for i=1:15
    [horizontal_corr, vertical_corr] = check_correlation(data.(trials{i}).channels,...
                                                         data.(trials{i}).eye_channels, corr_threshold);
    discard_channels_trial = [horizontal_corr, vertical_corr];  % channels discarded according to this trial
    discard_channels(discard_channels_trial) = discard_channels(discard_channels_trial)+1; % no += 1 :(
end
% channels wich have high(er than 'corr_threshold') correlation in (at least) 'trial_threshold' trials
data.discard = find(discard_channels > trial_thershold);
fprintf('%i channels discarded from analysis, because of high correlation!\n',size(data.discard,2));


%% temporal filtering
% this takes some time... (but way less than ICA eg.).
for i=1:15
   data.(trials{i}).channels = temporal_filter(data.(trials{i}).channels,Fs);
end
fprintf('temporal filtering done!\n')


%% save preprocessed dataset!
fName = sprintf('%s_1_preprocessed.mat',name);
save(fName, 'data');


%% create feature matrix == calc PSDs
% note: hard coded for 1sec epoching!

labels = [];  % will be a column vector; size: 15 * lenght trial (in sec)
features = [];  % feature matrix; size: size(labels,1) * (64*size(pxx,2))

for i=1:15  % iterates over trials
    len_trial = floor(size(data.(trials{i}).channels,2)/Fs);
    for k=0:len_trial-1  % iterates over seconds in the trial (1 by 1)
        % add label for every epoch
        labels = [labels; data.labels(i)];
        % calc PSD
        [pxx,f]  = calc_PSD(data.(trials{i}).channels(:,(k*Fs)+1:(k+1)*Fs),Fs);
        % cut pxx at 50Hz
        pxx = pxx(:,find(f<50))';  % transponent is needed for the next step! stupid MATLAB...
        % make a flat vector from 64*25 pxx matrix and extend feature matrix with a new row
        features = [features; pxx(:)'];
    end 
end
% save corresponding frequencies (at least once)
f = f(1,find(f<50));
data.f = f;
% save dataset (ready to do machine learning stuffs)
fName = sprintf('%s_1_ML.mat',name);
save(fName,'labels','features');
fprintf('feature matrix saved!\n')




%% ===================================== #TODO =====================================
fName = sprintf('%s_1_ML.mat',name);
load(fName);

%% PCA (just for transforming the feutures, no dim. reduction) / or just leave this out...
for i=1:15
    data.(trials{i}).bestindex = apply_pca(data.(trials{i}).power_spectrum);  % double check this!
end

%% feature selection
% features are the PSDs of the channels (data.t*.pxx)
% eg. see Data Analysis class codes

%% classify
% ... yup ...

