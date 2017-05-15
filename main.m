% main file for BCI project #ames !
% last update: 10/05 - Andras

%% Use this always =)

clc;
clear;
close all;

mac = 1; % flag for ICA -> change this to 1 on mac!

% labels are hard coded...
%name = 'Elisabetta';
%fName = '/home/bandi/EPFL/BCI/ag1_22032017.bdf'; % Elisabetta's 1st
%labels = [0,1,2,0,2,0,1,1,2,2,1,0,0,2,1]; % Elisabetta's 1st
%name = 'Mariana';
%fName = '/home/bandi/EPFL/BCI/ad10_13032017.bdf'; % Mariana's 1st
%labels = [0,2,0,0,2,0,2,2,1,1,1,1,2,1,0]; % Mariana's 1st
%name = 'Sharbat';
%fName = '/home/bandi/EPFL/BCI/ad3_08032017.bdf'; % Sharbat's 1st
%labels = [0,0,0,1,1,2,2,2,0,0,1,2,1,1,2]; % Sharbat's 1st
name = 'Andras';
fName = '/home/bandi/EPFL/BCI/ag2_22032017.bdf'; % Andras' 1st
labels = [0,2,0,1,2,2,0,0,0,1,1,1,2,2,1]; % Andras' 1st

Fs = 2048;

%% load in data from .bdf - use this for the 1st time!
[header, channels, eye_channels, biceps_channels, cleared_trigger] = initialize(fName);
saveName = sprintf('/home/bandi/EPFL/BCI/%s_1.mat',name);
data = save_to_mat(header, labels, channels, eye_channels, biceps_channels, cleared_trigger, saveName);
fprintf('data initialized and saved to .mat file!\n')


%% load in data from saved .mat file (struct of structs)
clc;
clear;
close all;

mac = 1; % flag for ICA -> change this to 1 on mac!

name = 'Sharbat';
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


%% temporal filtering
% this takes some time... (but way less than ICA eg.).
for i=1:15
   data.(trials{i}).channels = temporal_filter(data.(trials{i}).channels,Fs);
end
fprintf('temporal filtering done!\n')


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
    delete 'temp.*'
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


%% save preprocessed dataset!
fName = sprintf('%s_1_preprocessed.mat',name);
save(fName, 'data');


%% load in preprocessed dataset!
clc;
clear;
close all;
name = 'Sharbat';
fName = sprintf('%s_1_preprocessed.mat',name);
load(fName);
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
Fs = 256;

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
        pxx = pxx(:,find(f<50));
        % make a flat vector from 64*50 pxx matrix and extend feature matrix with a new row
        features = [features; reshape(pxx.',1,[])];
    end 
end
% discard all -Infs (some values, for the 0Hz freq. of PSD)
[rows, cols] = find(features == -Inf);
if isempty(rows) == 0
    labels(rows,:) = [];
    features(rows,:) = [];
end
% save corresponding frequencies (at least once)
f = f(1,find(f<50));
data.f = f;
% save dataset (ready to do machine learning stuffs)
fName = sprintf('%s_1_ML.mat',name);
save(fName,'labels','features');
fprintf('feature matrix saved!\n')


%% ===================================== #TODO =====================================
% load in feature matrix (and corresponding labels)
clc;
clear;
close all;
name = 'Sharbat';
fName = sprintf('%s_1_ML.mat',name);
load(fName);
% replace 2s with 1s in labels
labels(labels == 2) = 1;

%% plot PSD...
% plots 10 random easy and 10 random hard trial PSDs for the same electrodes
f = linspace(0,49,50); % this should be the same as data.f (if you don't change PSD window size, this should do it!)
plot_PSD(labels, features, f, name)

% close all;

%% Fisher's score:
[orderedPower, orderedInd] = fisher_rankfeat(features, labels);
disc = plot_fisher(orderedPower, orderedInd, name);


%% PCA (just for transforming the features, no dim. reduction) / or just leave this out...
% trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
% for i=1:15
%     data.(trials{i}).power_spectrum = powerSpect(data.(trials{i}).channels);  
% end
% 
% for i=1:15
%     data.(trials{i}).bestindex = apply_pca(data.(trials{i}).power_spectrum);  % double check this!
% end


%% MODEL SELECTION
%load('Andras_1_ML.mat');
train_features = features(1:900, :);
train_labels = labels(1:900);
%load('Sharbat_1_ML.mat');
test_features = features(901:end, :);
test_labels = labels(901:end);

%% Discriminant analysis - fitcdiscr
train_err = [];
test_err = []; 
class = cellstr(['diaglinear     ';
                 'linear         ';
                 'diagquadratic  ';
                 ]);
for selected_c = 1:length(class)          
classifiertype1 = char(class(selected_c));
disp(classifiertype1)
    
classifier = fitcdiscr(train_features, train_labels, 'discrimtype',  classifiertype1, 'ClassNames', [0 1 2]);

train_res = predict(classifier, train_features); 
train_err = [train_err classerror(train_res, train_labels)];

test_res = predict(classifier, test_features); 
test_err = [test_err classerror(test_res, test_labels)];

end

%% classify

% Naive Bayes classifiers - fitcnb
disp('Naive Bayes');
Mdl = fitcnb(train_features, train_labels);
train_res = predict(Mdl, train_features);
train_err = [train_err classerror(train_res, train_labels)];

test_res = predict(Mdl, test_features);
test_err = [test_err classerror(test_res, test_labels)];

% Support vector machines (multiclass) - fitcecoc
disp('SVM');
Mdl = fitcecoc(train_features, train_labels);
train_res = predict(Mdl, train_features);
train_err = [train_err classerror(train_res, train_labels)];


test_res = predict(Mdl, test_features);
test_err = [test_err classerror(test_res, test_labels)];
% %% Support vector machine (with CV)
% t = templateSVM('Standardize',1)
% Mdl = fitcecoc(features,v_labels, 'Learners',t) 
% CVMdl = crossval(Mdl);
% oosLoss = kfoldLoss(CVMdl) % classification error

%% PEFORMANCE EVALUATION
