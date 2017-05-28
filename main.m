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

name = 'Mariana';
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
name = 'Mariana';
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
        pxx = pxx(:,find(f<50));
        % calculate abs.power (integral of PSD curve) relative powers of given freq bands
        relative_powers = calc_powers(f, pxx);
        % make a flat vector from 64*50 pxx matrix, add powers (64*7 more features)
        features = [features; reshape(pxx.',1,[]), reshape(relative_powers.',1,[])];
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


%% ==================== Machine learning from here ====================

%% load in feature matrix (and corresponding labels)
clc;
clear;
close all;
name = 'Mariana';
fName = sprintf('%s_1_ML.mat',name);
load(fName);
% replace 2s with 1s in labels
labels(labels == 2) = 1;


%% plot PSD...
% plots 10 random easy and 10 random hard trial PSDs for the same electrodes
f = linspace(0,49,50); % this should be the same as data.f (if you don't change PSD window size, this should do it!)
features_PSD = features(:,1:end-(64*7)); % 7 is hard coded for 1+6diff bands (see calc_powers.m)
plot_PSD(labels, features_PSD, f, name)

close all;

%% Fisher's score:
[orderedPower, orderedInd] = fisher_rankfeat(features, labels);
disc = plot_fisher(orderedPower, orderedInd, name);
eeglab_path = '/usr/local/MATLAB/R2016a/toolbox/eeglab14_0_0b';
plot_fisher_topoplot(labels, features, eeglab_path, name);

%close all;


%% PCA (just for transforming the features, no dim. reduction) / or just leave this out...


%% reduce the number of features (based on Fisher score)
% reorder features
features_reord = features(:,orderedInd);
keep = 0.001; % best 0.1%
% reduce features to the best x %
features_red = features_reord(:,1:floor(size(features_reord,2)*keep));


%% 3D plot of reduced features (works only with 3 features...)
assert(size(features_red,2)==3,'Use only 3 features for this plot!');
% if you keep the 'keep' param at 0.001 -> only 3 features will remain and this plot should work!
figure;
scatter3(features_red(find(labels==0),1),features_red(find(labels==0),2),features_red(find(labels==0),3),'b','filled');
hold on;
scatter3(features_red(find(labels==1),1),features_red(find(labels==1),2),features_red(find(labels==1),3),'r','filled');
legend('easy', 'hard');

% loooool they are LINEARLY separable (for Andras)!


%% train (multiple) classifiers
clc;

% initialize partitions for n (10) fold CV
nfolds = 10;
%rng(1234); % set seed
cp = cvpartition(labels,'kfold',nfolds);

% initialize some containers to store results
train_errors = struct('linear',zeros(1,nfolds),'diaglinear',zeros(1,nfolds),'quadratic',zeros(1,nfolds),...
                      'diagquadratic',zeros(1,nfolds),'SVM',zeros(1,nfolds),'NB',zeros(1,nfolds));
test_errors = struct('linear',zeros(1,nfolds),'diaglinear',zeros(1,nfolds),'quadratic',zeros(1,nfolds),...
                      'diagquadratic',zeros(1,nfolds),'SVM',zeros(1,nfolds),'NB',zeros(1,nfolds));
true_pos_rates = struct('linear',zeros(1,nfolds),'diaglinear',zeros(1,nfolds),'quadratic',zeros(1,nfolds),...
                        'diagquadratic',zeros(1,nfolds),'SVM',zeros(1,nfolds),'NB',zeros(1,nfolds));  % only for test - conf. matrix...
false_pos_rates = struct('linear',zeros(1,nfolds),'diaglinear',zeros(1,nfolds),'quadratic',zeros(1,nfolds),...
                        'diagquadratic',zeros(1,nfolds),'SVM',zeros(1,nfolds),'NB',zeros(1,nfolds));  % only for test - conf. matrix...

for i=1:nfolds  % big CV loop with all the classifiers!  
    fprintf('CV loop: %i/%i\n',i,nfolds);
    
	test = features_red(cp.test(i),:);
    train = features_red(cp.training(i),:);
	labels_test = labels(cp.test(i));
	labels_train = labels(cp.training(i));
    
    % (no clever MATLAB way to update the struct... so let's do it 1 by 1)...
    % linear
    [train_errors.linear(1,i), test_errors.linear(1,i), ~, C_test] = train_LDQD(test, train, labels_test, labels_train, 'linear');
    [true_pos_rates.linear(1,i), false_pos_rates.linear(1,i)] = get_rates(C_test);
    
	% diaglinear
    [train_errors.diaglinear(1,i), test_errors.diaglinear(1,i), ~, C_test] = train_LDQD(test, train, labels_test, labels_train, 'diaglinear');
    [true_pos_rates.diaglinear(1,i), false_pos_rates.diaglinear(1,i)] = get_rates(C_test);
    
    % quadratic
    [train_errors.quadratic(1,i), test_errors.quadratic(1,i), ~, C_test] = train_LDQD(test, train, labels_test, labels_train, 'quadratic');
    [true_pos_rates.quadratic(1,i), false_pos_rates.quadratic(1,i)] = get_rates(C_test);
    
    % diagquadratic
    [train_errors.diagquadratic(1,i), test_errors.diagquadratic(1,i), ~, C_test] = train_LDQD(test, train, labels_test, labels_train, 'diagquadratic');
    [true_pos_rates.diagquadratic(1,i), false_pos_rates.diagquadratic(1,i)] = get_rates(C_test);
    
    % SVM
    [train_errors.SVM(1,i), test_erros.SVM(1,i), ~, C_test] = train_SVM(test, train, labels_test, labels_train);
    [true_pos_rates.SVM(1,i), false_pos_rates.SVM(1,i)] = get_rates(C_test);
    
    % Naive Bayes
    [train_errors.NB(1,i), test_erros.NB(1,i), ~, C_test] = train_NB(test, train, labels_test, labels_train);
    [true_pos_rates.NB(1,i), false_pos_rates.NB(1,i)] = get_rates(C_test);
end

fprintf('Classifiers trained!\n')


%% plot out train-test results

plot_errors(train_errors.linear, train_errors.diaglinear, train_errors.quadratic,...
            train_errors.diagquadratic, train_errors.SVM, train_errors.NB,...
            'train', name, nfolds);
plot_errors(test_errors.linear, test_errors.diaglinear, test_errors.quadratic,...
            test_errors.diagquadratic, test_errors.SVM, test_errors.NB,...
            'test', name, nfolds);
plot_ROC(false_pos_rates.linear, false_pos_rates.diaglinear, false_pos_rates.quadratic, false_pos_rates.diagquadratic, false_pos_rates.SVM, false_pos_rates.NB,...
         true_pos_rates.linear, true_pos_rates.diaglinear, true_pos_rates.quadratic, true_pos_rates.diagquadratic, true_pos_rates.SVM, true_pos_rates.NB, name);

