% main file for BCI project #ames !
% last update: 25/05 - Andras

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
saveName = sprintf('%s_1.mat',name);
data = save_to_mat(header, labels, channels, eye_channels, biceps_channels, cleared_trigger, saveName);
fprintf('data initialized and saved to .mat file!\n')


%% load in data from saved .mat file (struct of structs)
clc;
clear;
close all;

mac = 1; % flag for ICA -> change this to 1 on mac!

name = 'Andras';
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
   data.(trials{i}).channels = spatial_filer(data.(trials{i}).channels, 'Laplacian');
end
fprintf('spatial filtering done!\n')


%% temporal filtering
% this takes some time... (but way less than ICA eg.).
for i=1:15
   data.(trials{i}).channels = temporal_filter(data.(trials{i}).channels,Fs);
end
fprintf('temporal filtering done!\n')


%% apply ICA
% it's pretty slow and prints a lot!

eeglab_path = '/usr/local/MATLAB/R2016a/toolbox/eeglab14_0_0b';
addpath(sprintf('%s/functions/sigprocfunc',eeglab_path));

for i=1:15
   % calculate weight matrix
   [data.(trials{i}).weights, data.(trials{i}).sphere] = ICA(data.(trials{i}).channels, mac);
   % project dataset
   W = data.(trials{i}).weights * data.(trials{i}).sphere;  % unmixing matrix
   data.(trials{i}).channels = W * data.(trials{i}).channels;
end

if mac == 0 % delete generated (random) binary files on linux
    delete 'binica*'
    delete 'bias_after_adjust'
    delete 'temp.*'
end

fprintf('ICA done!\n')


%% check correlation (with eye movement)
% one can run from this after temporal filtering (and just skip the ICA part)
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
corr_threshold = 0.5;
trial_thershold = 7;
discard_channels = zeros(1,64);
for i=1:15
    [horizontal_corr, vertical_corr] = check_correlation(data.(trials{i}).channels,...
                                                         data.(trials{i}).eye_channels, down_, corr_threshold);
    discard_channels_trial = [horizontal_corr, vertical_corr];  % channels discarded according to this trial
    discard_channels(discard_channels_trial) = discard_channels(discard_channels_trial)+1; % no += 1 :(
end
% channels wich have high(er than 'corr_threshold') correlation in (at least) 'trial_threshold' trials
data.discard = find(discard_channels > trial_thershold);
fprintf('%i channels discarded from analysis, because of high correlation!\n',size(data.discard,2));

%% TODO: add the EOG artefact removal
% might be added to the code block above
% use mixing matrix inv(W) after rejection of components


%% save preprocessed dataset!
fName = sprintf('%s_1_preprocessed.mat',name);
save(fName, 'data');


%% load in preprocessed dataset!
clc;
clear;
close all;
name = 'Andras';
fName = sprintf('%s_1_preprocessed.mat',name);
load(fName);
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
Fs = 256;

%% create feature matrix == calc PSDs (+ integral of PSD)
% note: hard coded for 1sec epoching!

labels = [];  % will be a column vector; size: 15 * lenght trial (in sec)
features = [];  % feature matrix; size: size(labels,1) * (64*size(pxx,2)+64*7)

for i=1:15  % iterates over trials
    len_trial = floor(size(data.(trials{i}).channels,2)/Fs);
    for k=0:len_trial-1  % iterates over seconds in the trial (1 by 1)
        % add label for every epoch
        labels = [labels; data.labels(i)];
        % calc PSD
        [pxx,f]  = calc_PSD(data.(trials{i}).channels(:,(k*Fs)+1:(k+1)*Fs),Fs);
        % cut pxx at 50Hz
        f = f(find(2<=f & f<=45));
        pxx = pxx(:,f);
        % calculate abs.power (integral of PSD curve) relative powers of given freq bands
        relative_powers = calc_powers(f, pxx);
        % make a flat vector from 64*44 pxx matrix, add powers (64*7 more features)
        features = [features; reshape(pxx.',1,[]), reshape(relative_powers.',1,[])];
    end 
end

% save corresponding frequencies (at least once)
%data.f = f;

% discard all -Infs (some values, for the 0Hz freq. of PSD)
[rows, cols] = find(features == -Inf);
if isempty(rows) == 0
    labels(rows,:) = [];
    features(rows,:) = [];
end

% save dataset (ready to do machine learning stuffs)
fName = sprintf('%s_1_ML.mat',name);
save(fName,'labels','features');
fprintf('feature matrix saved!\n')


%% ==================== Machine learning from here ====================

%% load in feature matrix (and corresponding labels)
clc;
clear;
close all;
name = 'Andras';
fName = sprintf('%s_1_ML.mat',name);
load(fName);
% replace 2s with 1s in labels
labels(labels == 2) = 1;


%% plot PSD...
% plots 10 random easy and 10 random hard trial PSDs for the same electrodes
f = linspace(2,45,44); % this should be the same as data.f (if you don't change PSD window size, this should do it!)
features_PSD = features(:,1:end-(64*7)); % 7 is hard coded for 1+6diff bands (see calc_powers.m)
plot_PSD(labels, features_PSD, f, name)

close all;

%% Fisher's score:
[orderedPower, orderedInd] = fisher_rankfeat(features, labels);
disc = plot_fisher(orderedPower, orderedInd, name);
eeglab_path = '/usr/local/MATLAB/R2016a/toolbox/eeglab14_0_0b';
plot_fisher_topoplot(labels, features, eeglab_path, name);


%% PCA (just for transforming the features, no dim. reduction) / or just leave this out...


%% reduce the number of features (based on Fisher score)
% reorder features
features_reord = features(:,orderedInd);
keep = 30;
features_red = features_reord(:,1:keep);


%% 3D plot of reduced features
features_plot3d = features_red(:,1:3);
plot_features_3D(labels, features_plot3d, name)


%% train (multiple) classifiers
clc;

% initialize partitions for n (10) fold CV
nfolds = 10;
% make sure that partitions have equal number of samples (for ROC curve with CV...)
features_red = features_red(1:floor(size(labels,1)/10)*10,:);
labels = labels(1:floor(size(labels,1)/10)*10,:);
%rng(1234); % set seed
cp = cvpartition(labels,'kfold',nfolds);

% initialize some containers to store results
train_errors = struct('linear',ones(1,nfolds),'diaglinear',ones(1,nfolds),'quadratic',ones(1,nfolds),...
                      'diagquadratic',ones(1,nfolds),'SVM',ones(1,nfolds),'NB',ones(1,nfolds));
test_errors = struct('linear',ones(1,nfolds),'diaglinear',ones(1,nfolds),'quadratic',ones(1,nfolds),...
                      'diagquadratic',ones(1,nfolds),'SVM',ones(1,nfolds),'NB',ones(1,nfolds));
tmp = floor(size(labels,1)/nfolds)+1;
ROC = struct('linear_x',[],'linear_y',[],'linear_AUC',zeros(nfolds,1),...
             'diaglinear_x',[],'diaglinear_y',[],'diaglinear_AUC',zeros(nfolds,1),...
             'quadratic_x',[],'quadratic_y',[],'quadratic_AUC',zeros(nfolds,1),...
             'diagquadratic_x',[],'diagquadratic_y',[],'diagquadratic_AUC',zeros(nfolds,1),...
             'SVM_x',[],'SVM_y',[],'SVM_AUC',zeros(nfolds,1),...
             'NB_x',[],'NB_y',[],'NB_AUC',zeros(nfolds,1),...
             'best_AUCs',ones(1,6));

for i=1:nfolds  % big CV loop with all the classifiers!  
    fprintf('CV loop: %i/%i\n',i,nfolds);
    
    %TODO: replace partitioning with cont. samples!!! -eg. write function cvpartition_EEG to make similar structure that cvpartition
	test = features_red(cp.test(i),:);
    train = features_red(cp.training(i),:);
	labels_test = labels(cp.test(i));
	labels_train = labels(cp.training(i));
    
    % (no clever MATLAB way to update the struct... so let's do it 1 by 1)...
    % linear
    [train_errors.linear(1,i), test_errors.linear(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.linear_AUC(i,1)] = train_LDQD(test, train, labels_test, labels_train, 'linear');
    if i == 1 || test_errors.linear(1,i) < min(test_errors.linear(1,1:i-1))
        ROC.linear_x = ROC_x;  ROC.linear_y = ROC_y; ROC.best_AUCs(1,1) = ROC.linear_AUC(i,1);
    end
    
	% diaglinear
    [train_errors.diaglinear(1,i), test_errors.diaglinear(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.diaglinear_AUC(i,1)] = train_LDQD(test, train, labels_test, labels_train, 'diaglinear');
    if i == 1 || test_errors.diaglinear(1,i) < min(test_errors.diaglinear(1,1:i-1))
        ROC.diaglinear_x = ROC_x;  ROC.diaglinear_y = ROC_y; ROC.best_AUCs(1,2) = ROC.diaglinear_AUC(i,1);
    end
    
    % quadratic
    [train_errors.quadratic(1,i), test_errors.quadratic(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.quadratic_AUC(i,1)] = train_LDQD(test, train, labels_test, labels_train, 'quadratic');
    if i == 1 || test_errors.quadratic(1,i) < min(test_errors.quadratic(1,1:i-1))
        ROC.quadratic_x = ROC_x;  ROC.quadratic_y = ROC_y; ROC.best_AUCs(1,3) = ROC.quadratic_AUC(i,1);
    end
    
    % diagquadratic
    [train_errors.diagquadratic(1,i), test_errors.diagquadratic(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.diagquadratic_AUC(i,1)] = train_LDQD(test, train, labels_test, labels_train, 'diagquadratic');
    if i == 1 || test_errors.diagquadratic(1,i) < min(test_errors.diagquadratic(1,1:i-1))
        ROC.diagquadratic_x = ROC_x;  ROC.diagquadratic_y = ROC_y; ROC.best_AUCs(1,4) = ROC.diagquadratic_AUC(i,1);
    end
                                                                                              
    % SVM
    [train_errors.SVM(1,i), test_errors.SVM(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.SVM_AUC(i,1)] = train_SVM(test, train, labels_test, labels_train);
    if i == 1 || test_errors.SVM(1,i) < min(test_errors.SVM(1,1:i-1))
        ROC.SVM_x = ROC_x;  ROC.SVM_y = ROC_y; ROC.best_AUCs(1,5) = ROC.SVM_AUC(i,1);
    end
    
    % Naive Bayes
    [train_errors.NB(1,i), test_errors.NB(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.NB_AUC(i,1)] = train_NB(test, train, labels_test, labels_train);
    if i == 1 || test_errors.NB(1,i) < min(test_errors.NB(1,1:i-1))
        ROC.NB_x = ROC_x;  ROC.NB_y = ROC_y; ROC.best_AUCs(1,6) = ROC.NB_AUC(i,1);
    end
end

fprintf('Classifiers trained!\n')


%% plot out train-test results

plot_errors(train_errors.linear, train_errors.diaglinear, train_errors.quadratic,...
            train_errors.diagquadratic, train_errors.SVM, train_errors.NB,...
            'train', name, nfolds);
        
plot_errors(test_errors.linear, test_errors.diaglinear, test_errors.quadratic,...
            test_errors.diagquadratic, test_errors.SVM, test_errors.NB,...
            'test', name, nfolds);
        
plot_ROC(ROC.linear_x, ROC.diaglinear_x, ROC.quadratic_x, ROC.diagquadratic_x, ROC.SVM_x, ROC.NB_x,...
         ROC.linear_y, ROC.diaglinear_y, ROC.quadratic_y, ROC.diagquadratic_y, ROC.SVM_y, ROC.NB_y, name, ROC.best_AUCs);

