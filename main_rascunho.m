% main file for BCI project #ames !
% last update: 10/05 - Andras

clc;
clear;
close all;

%%
mac = 1; % flag for ICA -> change this to 1 on mac!

% labels are hard coded...
%name = 'Elisabetta';
%fName = 'ag1_22032017.bdf'; % Elisabetta's 1st
%labels = [0,1,2,0,2,0,1,1,2,2,1,0,0,2,1]; % Elisabetta's 1st
name = 'Mariana';
fName = 'ad10_13032017.bdf'; % Mariana's 1st
labels = [0,2,0,0,2,0,2,2,1,1,1,1,2,1,0]; % Mariana's 1st
% name = 'Sharbat';
% fName = 'ad3_08032017.bdf'; % Sharbat's 1st
% labels = [0,0,0,1,1,2,2,2,0,0,1,2,1,1,2]; % Sharbat's 1st
% name = 'Andras';
% fName = 'ag2_22032017.bdf'; % Andras' 1st
% labels = [0,2,0,1,2,2,0,0,0,1,1,1,2,2,1]; % Andras' 1st
% 
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
addpath(['./eegplot']);

name = 'Mariana';
fName = sprintf('%s_1.mat',name);
load(fName);
Fs = 2048;
fprintf('data loaded!\n')

% description of the data format:
% struct (called data) with the original header, labels and 15 structs inside (for each trials).
% trials have 4 matrices, channels, eye_channels, biceps_channels and cleared_trigger (access like: data.t1.channels)
% feel free to extend with more fields! (data.* = )
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...


%% downsample EEG channels
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

%% spatial filtering 2 - disgusting results :P
% for i=1:15
%    data.(trials{i}).channels = CAR(data.(trials{i}).channels);
% end
% fprintf('spatial filtering done!\n')

%% temporal filtering % useful to decrease correlation_
% this takes some time... (but way less than ICA eg.).
for i=1:15
   data.(trials{i}).channels = temporal_filter(data.(trials{i}).channels,Fs);
end
fprintf('temporal filtering done!\n')

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


%% Do PSD and create feature matrix

labels = [];  % will be a column vector; size: 15 * lenght trial (in sec)
features = [];  % feature matrix; size: size(labels,1) * (64*size(pxx,2))
power = [];
power_delta = [];
power_theta = [];
power_alpha = [];
power_low_beta = [];
power_high_beta = [];
power_gamma = [];

pos=1;
for i=1:15  % iterates over trials 
    len_trial = floor(size(data.(trials{i}).channels,2)/Fs);
    tot_len_trial(pos)=len_trial;
    pos=pos+1;
    for k=0:len_trial-1  % iterates over seconds in the trial (1 by 1)
        % add label for every epoch
        labels = [labels; data.labels(i)];
        % calc PSD
        [pxx,f]  = calc_PSD(data.(trials{i}).channels(:,(k*Fs)+1:(k+1)*Fs),Fs);
        % cut pxx at 50Hz
        pxx = pxx(:,find(f<40));
        % make a flat vector from 64*50 pxx matrix and extend feature matrix with a new row
        features = [features; reshape(pxx.',1,[])];
        power = [power; trapz(pxx')];
    
        %delta (2?4 Hz)
        pxx2 = pxx(:,find(f>=2 & f<=4));
        power_delta = [power_delta; trapz(pxx2')];

        %theta (4?8 Hz),
        pxx2 = pxx(:,find(f>=4 & f<=8));
        power_theta = [power_theta; trapz(pxx2')];

        %alpha (8?13 Hz), 
        pxx2 = pxx(:,find(f>=8 & f<=13));
        power_alpha = [power_alpha; trapz(pxx2')];

        %low beta (13?18 Hz), 
        pxx2 = pxx(:,find(f>=13 & f<=18));
        power_low_beta = [power_low_beta; trapz(pxx2')];

        %high beta (18?30 Hz),
        pxx2 = pxx(:,find(f>=18 & f<=30));
        power_high_beta = [power_high_beta; trapz(pxx2')];

        %gamma (30?45 Hz) 
        pxx2 = pxx(:,find(f>=30 & f<40));
        power_gamma = [power_gamma; trapz(pxx2')];

    end 
    
end

%Relative powers
rel_power_delta = power_delta./power;
rel_power_alpha = power_alpha./power;
rel_power_theta = power_theta./power;
rel_power_low_beta = power_low_beta./power;
rel_power_high_beta = power_high_beta./power;
rel_power_gamma = power_gamma./power;


% structure of the feature matrix:
%                   channel 1           | channel 2           |...
%                   frequency range     | frequency range     |...
% trial 1 | seconds  
% trial 2 | seconds
% ...
% ...
% 


%% ~ average the PSD of all seconds, for each trial and for each channel
freq=size(pxx,2);

cumtot=cumsum(tot_len_trial);
cumtot=[0 cumtot];

for i=1:15
    pos_min=cumtot(i);
    pos_max=cumtot(i+1);
    for j=1:freq:size(features,2)-freq+1
        
        mean_features(i,j:j+freq-1)=mean(features(pos_min+1:pos_max,j:j+freq-1));
    
    end
end


%% ~ plot the averaged PSD for the first channel, all trials
figure
hold on
for i=1:size(mean_features,1)
    if data.labels(i)==0
        plot(mean_features(i,1:40)','b')
    elseif data.labels(i)==1
        plot(mean_features(i,1:40)','g')
    else
        plot(mean_features(i,1:40)','r')
    end
end

%% ~ calculate the integral of each spectrum
% (shifted to above the x axis - we just want the area below the curve)

area_easy=trapz(mean(mean_features(data.labels==0,1:40))'-min(mean(mean_features(data.labels==0,1:40))')); 
area_medium=trapz(mean(mean_features(data.labels==1,1:40))'-min(mean(mean_features(data.labels==1,1:40))'));
area_hard=trapz(mean(mean_features(data.labels==2,1:40))'-min(mean(mean_features(data.labels==2,1:40))'));


% Andras:
% area_easy= 349.8410
% area_medium= 373.8091
% area_hard= 342.6626

% Elisabetta:
% area_easy= 237.3205
% area_medium= 270.3549
% area_hard= 234.0168

% Mariana
% area_easy= 167.7832
% area_medium= 175.3667
% area_hard= 189.4599

% Sharbat
% area_easy= 207.4862
% area_medium= 193.1525
% area_hard= 182.1873



%% ~ plot the mean of the trials (with labels, of course :P )
% for channel 1

figure
plot(mean(mean_features(data.labels==0,1:40))')
hold on
plot(mean(mean_features(data.labels==1,1:40))')
plot(mean(mean_features(data.labels==2,1:40))')
legend('easy','medium','hard')
title(sprintf('%s: average psd for each label', name));

%% ~ let's try for all channels (GOGOGO!!)
%change area
figure
hold on
pos=1;
for j=1:freq:size(features,2)-freq+1
    subplot(8,8,pos)
    plot(mean(mean_features(data.labels==0,j:j+freq-1))')
    hold on
    plot(mean(mean_features(data.labels==1,j:j+freq-1))')
    plot(mean(mean_features(data.labels==2,j:j+freq-1))')
    title(sprintf('%s - Channel %i', name, pos));
    area_labels(pos,1)=trapz(mean(mean_features(data.labels==0,j:j+freq-1))'-min(mean(mean_features(data.labels==0,j:j+freq-1))'));
    area_labels(pos,2)=trapz(mean(mean_features(data.labels==1,j:j+freq-1))'-min(mean(mean_features(data.labels==1,j:j+freq-1))'));
    area_labels(pos,3)=trapz(mean(mean_features(data.labels==2,j:j+freq-1))'-min(mean(mean_features(data.labels==2,j:j+freq-1))'));
    pos=pos+1;
end
legend('easy','medium','hard')

%% ~ Fisher's score:
[orderedPower, orderedInd] = fisher_rankfeat(power, labels);
disc = plot_fisher(orderedPower, orderedInd, name);

scores = [];
for i=1:length(orderedPower)
   scores(i) = orderedPower(find(orderedInd ==i));
end
%% ~ Plot topographic map of Fisher's score
%A = imread('head.png');
%image(A)
A = textread('coord.txt', '%f');
X = A(1:2:end);
Y = A(2:2:end);
N=64;
ch = [X,Y];
addpath(['./eegplot/eegplot']);
eegplot(scores',ch,[],[],[],[]);
title('areas fisher scores');
% figure;
% imshow(brain);

%"increasing task difficulty led to right-parietal and posttemporal alpha
%acceleration for all tasks"
%Increasing alpha power
%% save dataset (ready to do machine learning stuffs)
fName = sprintf('%s_1_ML.mat',name);
save(fName,'labels','features');
fprintf('feature matrix saved!\n')




%% MODEL SELECTION

%% Load data
clc;
clear all
close all
name = 'Mariana';
fName = sprintf('%s_1_ML', name);
load(fName);

%% ~ Try with only 2 classes
% labels(find(labels ==2))=1;

%% partition
cp = cvpartition(labels, 'kfold', 5);
train_features = power_delta(cp.training(1), :);
train_labels = labels(cp.training(1),:);
test_features = power_delta(cp.test(1),:);
test_labels = labels(cp.test(1),:);

%% NOT USE - this is disgusting
% train_features = areas([1:900], :);
% train_labels = labels([1:900],:);
% test_features = areas([901:end],:);
% test_labels = labels([901:end],:);

%% Discriminant analysis - fitcdiscr
train_err = [];
test_err = []; 
class = cellstr(['diaglinear     ';
                 'linear         ';
                 'diagquadratic  ';
                 'quadratic      ']);
for selected_c = 1:length(class)          
classifiertype1 = char(class(selected_c));
disp(classifiertype1)
    
classifier = fitcdiscr(train_features, train_labels, 'discrimtype',  classifiertype1, 'ClassNames', [0 1 2]);

train_res = predict(classifier, train_features); 
train_err = [train_err classerror(train_res, train_labels)];

test_res = predict(classifier, test_features); 
test_err = [test_err classerror(test_res, test_labels)]

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



%% Support vector machine (with CV)
t = templateSVM('Standardize',1)
Mdl = fitcecoc(power,labels, 'Learners',t) 
CVMdl = crossval(Mdl);
oosLoss = kfoldLoss(CVMdl) % classification error




%% from now on, no other changes were made on the code
















%% ===================================== #TODO =====================================
% load in feature matrix (and corresponding labels)


%% plot PSD...
% plots 10 random easy and 10 random hard trial PSDs for the same electrodes
f = linspace(0,40,40); % this should be the same as data.f (if you don't change PSD window size, this should do it!)
figure
plot_PSD(labels, features, f, name)

% close all;



%% PCA (just for transforming the features, no dim. reduction) / or just leave this out...
% trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
% for i=1:15
%     data.(trials{i}).power_spectrum = powerSpect(data.(trials{i}).channels);  
% end
% 
% for i=1:15
%     data.(trials{i}).bestindex = apply_pca(data.(trials{i}).power_spectrum);  % double check this!
% end



%% PEFORMANCE EVALUATION
