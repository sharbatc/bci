% main file for BCI project - 1st session #ames !

clc;
clear;
close all;

% labels are hard coded...
%name = 'Elisabetta';
%fName = '/home/bandi/EPFL/BCI/ag1_22032017.bdf'; % Elisabetta's 1st
% fName = '/Users/sharbatc/Academia/Projects/BCI/data/ag1_22032017.bdf';
%labels = [0,1,2,0,2,0,1,1,2,2,1,0,0,2,1];

%name = 'Mariana';
%fName = '/home/bandi/EPFL/BCI/ad10_13032017.bdf'; % Mariana's 1st
% fName = '/Users/sharbatc/Academia/Projects/BCI/data/ad10_13032017.bdf';
%labels = [0,2,0,0,2,0,2,2,1,1,1,1,2,1,0];

% name = 'Sharbat';
% fName = '/home/bandi/EPFL/BCI/ad3_08032017.bdf'; % Sharbat's 1st
% fName = '/Users/sharbatc/Academia/Projects/BCI/data/ad3_08032017.bdf';
% labels = [0,0,0,1,1,2,2,2,0,0,1,2,1,1,2];

name = 'Andras';
% fName = '/home/bandi/EPFL/BCI/ag2_22032017.bdf'; % Andras' 1st
fName = '/Users/sharbatc/Academia/Projects/BCI/data/ag2_22032017.bdf';
labels = [0,2,0,1,2,2,0,0,0,1,1,1,2,2,1];

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

mac = 0; % flag for ICA -> change this to 1 on mac!

name = 'Sharbat';
fName = sprintf('%s_1.mat',name);
load(fName);
Fs = 2048;
fprintf('data loaded!\n');

% description of the data format:
% struct (called data) with the original header, labels and 15 structs inside (for each trials).
% trials have 4 matrices, channels, eye_channels, biceps_channels and cleared_trigger (access like: data.t1.channels)
% feel free to extend with more fields! (data.* = )

%% Behavioural analysis
behav_analysis(data, name);


%% downsample EEG channels
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
down_ = 8; %-> new Fs = 256 Hz
for i=1:15
   data.(trials{i}).channels = data.(trials{i}).channels(:,1:down_:end);
end
Fs = Fs/down_;
fprintf('EEG downsampled by %i!\n',down_)


%% temporal filtering
% this takes some time... (but way less than ICA eg.).
for i=1:15
   data.(trials{i}).channels = temporal_filter(data.(trials{i}).channels,Fs);
end
fprintf('temporal filtering done!\n')


%% apply ICA
% it's pretty slow!
eeglab_path = '/usr/local/MATLAB/R2016a/toolbox/eeglab14_0_0b';
%eeglab_path = '/Applications/MATLAB_R2016b.app/toolbox/eeglab14_1_0b';
addpath(sprintf('%s/functions/sigprocfunc',eeglab_path));
ncomponents = 50; % number of components to keep (change this to avoid complex values)
for i=1:15
    fprintf('decomposing trial %i!\n',i);
    [data.(trials{i}).ICAactivations, data.(trials{i}).W, data.(trials{i}).invW] = ICA(data.(trials{i}).channels, ncomponents, mac);
    assert(isreal(data.(trials{i}).ICAactivations) == 1, 'Complex values after ICA, consider using less components!')
    %TODO: add ICA weight saving!
end
fprintf('ICA decomposition done!\n')


%% check correlation: ICA activations with (horizontal & vertical) eye movement
ses = 1;  % session ID for figures...
threshold = 2;  % 2*std
for i=1:15
    [horizontal_corr, vertical_corr] = check_correlation(data.(trials{i}).ICAactivations, data.(trials{i}).eye_channels,...
                                                         down_, threshold, eeglab_path, ses, i, name);
    data.(trials{i}).remove = union(horizontal_corr, vertical_corr);                                            
end
close all;


%% remove components with high corr. and reconstruct the signal
for i=1:15
        data.(trials{i}).invW(:,data.(trials{i}).remove) = 0;  % remove components
        data.(trials{i}).channels = data.(trials{i}).invW * data.(trials{i}).ICAactivations;
end
fprintf('signal recomposed!\n')


%% spatial filtering
for i=1:15
   data.(trials{i}).channels = spatial_filer(data.(trials{i}).channels, 'Laplacian');
end
fprintf('spatial filtering done!\n')


%% save preprocessed dataset!
fName = sprintf('%s_%i_preprocessed.mat',name,ses);
save(fName, 'data', 'Fs', 'trials');


%% ==================== end of preprocessing ====================


%% load in preprocessed dataset!
clc;
clear;
close all;

ses = 1;  % session ID
name = 'Elisabetta';
fName = sprintf('%s_%i_preprocessed.mat',name,ses);
load(fName);


%% create feature matrix == calc PSDs (+ integral of PSD)
% note: hard coded for 1sec epoching!
%TODO: change for ovelapping windows

labels = [];  % will be a column vector; size: 15 * lenght trial (in sec)
features = [];  % feature matrix; size: size(labels,1) * (64*size(pxx,2)+64*7)

for i=1:15  % iterates over trials
    %fprintf('processing trial %i!\n',i);
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

% save dataset (ready to do machine learning stuffs)
fName = sprintf('%s_%i_ML.mat',name,ses);
save(fName,'labels','features','f');
fprintf('feature matrix saved!\n')


%% ==================== Machine learning from here ====================


%% load in feature matrix (and corresponding labels)
clc;
clear;
close all;

ses = 1;  % session ID
name = 'Elisabetta';
fName = sprintf('%s_%i_ML.mat',name,ses);
load(fName);

% replace 2s with 1s in labels (pool hard & hard with assistance)
labels(labels == 2) = 1;


%% plot PSD...
% plots 10 random easy and 10 random hard trial PSDs for the same electrodes
features_PSD = features(:,1:end-(64*7)); % 7 is hard coded for 1+6diff bands (see calc_powers.m)
plot_PSD(labels, features_PSD, f, ses, name)
close all;


%% Fisher's score:
[orderedPower, orderedInd] = fisher_rankfeat(features, labels);
disc = plot_fisher(orderedPower, orderedInd, ses, name);
eeglab_path = '/usr/local/MATLAB/R2016a/toolbox/eeglab14_0_0b';
%plot_fisher_topoplot(labels, features, eeglab_path, ses, name);


%% reduce the number of features (based on Fisher score)
% reorder features
features_reord = features(:,orderedInd);
keep = 30;
features_red = features_reord(:,1:keep);


%% 3D plot of reduced features
features_plot3d = features_red(:,1:3);
plot_features_3D(labels, features_plot3d, ses, name);


%% train (multiple) classifiers
clc;

% initialize partitions for 10 fold CV
nfolds = 10;
cp = cvpartition_EEG(labels,nfolds);

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
             'best_AUCs',zeros(1,6));

for i=1:nfolds  % big CV loop with all the classifiers!  
    fprintf('CV loop: %i/%i\n',i,nfolds);
    
	test = features_red(cp.test(i,:),:);
    train = features_red(cp.training(i,:),:);
	labels_test = labels(cp.test(i,:));
	labels_train = labels(cp.training(i,:));
    
    % (no clever MATLAB way to update the struct... so let's do it 1 by 1)...
    % linear
    [train_errors.linear(1,i), test_errors.linear(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.linear_AUC(i,1), classifier] = train_LDQD(test, train, labels_test, labels_train, 'linear');
    if i == 1 || test_errors.linear(1,i) < min(test_errors.linear(1,1:i-1))
        ROC.linear_x = ROC_x;  ROC.linear_y = ROC_y; ROC.best_AUCs(1,1) = ROC.linear_AUC(i,1);
        fName = sprintf('classifiers/s%i_%s_linear',ses,name);
        save(fName,'classifier','orderedInd','keep');
    end
    
	% diaglinear
    [train_errors.diaglinear(1,i), test_errors.diaglinear(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.diaglinear_AUC(i,1), classifier] = train_LDQD(test, train, labels_test, labels_train, 'diaglinear');
    if i == 1 || test_errors.diaglinear(1,i) < min(test_errors.diaglinear(1,1:i-1))
        ROC.diaglinear_x = ROC_x;  ROC.diaglinear_y = ROC_y; ROC.best_AUCs(1,2) = ROC.diaglinear_AUC(i,1);
        fName = sprintf('classifiers/s%i_%s_diaglinear',ses,name);
        save(fName,'classifier','orderedInd','keep');
    end
    
    % quadratic
    [train_errors.quadratic(1,i), test_errors.quadratic(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.quadratic_AUC(i,1), classifier] = train_LDQD(test, train, labels_test, labels_train, 'quadratic');
    if i == 1 || test_errors.quadratic(1,i) < min(test_errors.quadratic(1,1:i-1))
        ROC.quadratic_x = ROC_x;  ROC.quadratic_y = ROC_y; ROC.best_AUCs(1,3) = ROC.quadratic_AUC(i,1);
        fName = sprintf('classifiers/s%i_%s_quadratic',ses,name);
        save(fName,'classifier','orderedInd','keep');
    end
    
    % diagquadratic
    [train_errors.diagquadratic(1,i), test_errors.diagquadratic(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.diagquadratic_AUC(i,1),classifier] = train_LDQD(test, train, labels_test, labels_train, 'diagquadratic');
    if i == 1 || test_errors.diagquadratic(1,i) < min(test_errors.diagquadratic(1,1:i-1))
        ROC.diagquadratic_x = ROC_x;  ROC.diagquadratic_y = ROC_y; ROC.best_AUCs(1,4) = ROC.diagquadratic_AUC(i,1);
        fName = sprintf('classifiers/s%i_%s_diagquadratic',ses,name);
        save(fName,'classifier','orderedInd','keep');
    end
                                                                                              
    % SVM
    [train_errors.SVM(1,i), test_errors.SVM(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.SVM_AUC(i,1), classifier] = train_SVM(test, train, labels_test, labels_train);
    if i == 1 || test_errors.SVM(1,i) < min(test_errors.SVM(1,1:i-1))
        ROC.SVM_x = ROC_x;  ROC.SVM_y = ROC_y; ROC.best_AUCs(1,5) = ROC.SVM_AUC(i,1);
        fName = sprintf('classifiers/s%i_%s_SVM',ses,name);
        save(fName,'classifier','orderedInd','keep');
    end
    
    % Naive Bayes
    [train_errors.NB(1,i), test_errors.NB(1,i), ~, ~,...
     ROC_x, ROC_y, ROC.NB_AUC(i,1), classifier] = train_NB(test, train, labels_test, labels_train);
    if i == 1 || test_errors.NB(1,i) < min(test_errors.NB(1,1:i-1))
        ROC.NB_x = ROC_x;  ROC.NB_y = ROC_y; ROC.best_AUCs(1,6) = ROC.NB_AUC(i,1);
        fName = sprintf('classifiers/s%i_%s_NB',ses,name);
        save(fName,'classifier','orderedInd','keep');
    end
end

fprintf('Classifiers trained!\n')


%% plot out train-test results

plot_errors(train_errors.linear, train_errors.diaglinear, train_errors.quadratic,...
            train_errors.diagquadratic, train_errors.SVM, train_errors.NB,...
            'train', ses, name, nfolds);
        
plot_errors(test_errors.linear, test_errors.diaglinear, test_errors.quadratic,...
            test_errors.diagquadratic, test_errors.SVM, test_errors.NB,...
            'test', ses, name, nfolds);
        
plot_ROC(ROC.linear_x, ROC.diaglinear_x, ROC.quadratic_x, ROC.diagquadratic_x, ROC.SVM_x, ROC.NB_x,...
         ROC.linear_y, ROC.diaglinear_y, ROC.quadratic_y, ROC.diagquadratic_y, ROC.SVM_y, ROC.NB_y, ses, name, ROC.best_AUCs);

