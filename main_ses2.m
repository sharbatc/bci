%% Load the data
clc;
clear;
close all;

mac = 1;

% name = 'Mariana';
% fName = '/Users/sharbatc/Academia/Projects/BCI/data/ad10_03042017.bdf';
% labels = [1,2,0,2,1,2,1,1,1,0,0,2,0,0,2];

% name = 'Elisabetta';
% fName = '/Users/sharbatc/Academia/Projects/BCI/data/ag1_26042017.bdf';
% labels = [1,2,0,2,1,2,1,1,1,0,0,2,0,0,2];

% name = 'Andras';
% fName = '/Users/sharbatc/Academia/Projects/BCI/data/ag2_05042017.bdf';
% labels = [1,2,0,2,1,2,1,1,1,0,0,2,0,0,2];

name = 'Sharbat';
fName = '/Users/sharbatc/Academia/Projects/BCI/data/ad3_05042017.bdf';
labels = [1,2,0,2,1,2,1,1,1,0,0,2,0,0,2];


Fs = 2048;

%% load in data from .bdf - use this for the 1st time!
[header, channels, eye_channels, biceps_channels, cleared_trigger_ses2] = initialize_ses2(fName);
saveName = sprintf('%s_2.mat',name);
data = save_to_mat_ses2(header, labels, channels, eye_channels, biceps_channels, cleared_trigger_ses2, saveName);
fprintf('data for ses2 initialized and saved to .mat file!\n')


%% load in data from saved .mat file (struct of structs)
clc;
clear;
close all;

mac = 1; % flag for ICA -> change this to 1 on mac!



name = 'Sharbat';
fName = sprintf('%s_2.mat',name);
load(fName);
Fs = 2048;
fprintf('ses2 data loaded!\n');

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
% it's pretty slow!
%eeglab_path = '/usr/local/MATLAB/R2016a/toolbox/eeglab14_0_0b';
eeglab_path = '/Applications/MATLAB_R2016b.app/toolbox/eeglab14_1_0b';
addpath(sprintf('%s/functions/sigprocfunc',eeglab_path));
ncomponents = 45; % number of components to keep (change this to avoid complex values)
for i=1:15
    fprintf('decomposing trial %i!\n',i);
    % calculate weight matrix   
    [data.(trials{i}).ICAactivations, data.(trials{i}).W, data.(trials{i}).invW] = ICA(data.(trials{i}).channels, ncomponents, mac);
    assert(isreal(data.(trials{i}).ICAactivations) == 1, 'Complex values after ICA, consider using less components!')
end
fprintf('ICA decomposition done!\n')

%% check correlation: ICA activations with (horizontal & vertical) eye movement
threshold = 2;  % 2*std
for i=1:15
    [horizontal_corr, vertical_corr] = check_correlation(data.(trials{i}).ICAactivations, data.(trials{i}).eye_channels,...
                                                         down_, threshold, eeglab_path, i, name);
    data.(trials{i}).remove = union(horizontal_corr, vertical_corr);                                            
end
close all;

%% remove components with high corr. and reconstruct the signal
for i=1:15
        data.(trials{i}).invW(:,data.(trials{i}).remove) = 0;  % remove components
        data.(trials{i}).channels = data.(trials{i}).invW * data.(trials{i}).ICAactivations;
end
fprintf('signal recomposed!\n')

%% save preprocessed dataset!
fName = sprintf('%s_2_preprocessed.mat',name);
save(fName, 'data', 'Fs', 'trials');

%% ==================== end of preprocessing ====================


%% load in preprocessed dataset!
clc;
clear;
close all;
name = 'Sharbat';
fName = sprintf('%s_2_preprocessed.mat',name);
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
        if data.(trials{i}). 
        labels = [labels; 0];
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
fName = sprintf('%s_1_ML.mat',name);
save(fName,'labels','features','f');
fprintf('feature matrix saved!\n')
