
function filtered_trials = filterChannels(matrix_channels)

%% BP Filter

%2048 Hz sampling rate

D = designfilt('lowpassiir','FilterOrder',20,'HalfPowerFrequency' ,40,'SampleRate',2048,'DesignMethod','butter');
filtered_signal = filter(D, matrix_channels'); 

% % plot filtered signal
% S = size(matrix_channels,2);
% L = S(2);                           % Length of signal
% time=0:L-1;
% time=time/2048;


%% Spatial filter

chanfile = '10-20_biosemi.txt'; % absolute or relative path
capsize = 58; % cm
laplaciansize = 5; % cm
electrodes = 1:64;

% datain -> (time_points, channels)

coordinates = proc_coordinates(chanfile, capsize, laplaciansize, electrodes);


[filtered_trials_T, mask, layout] = proc_lap(filtered_signal, coordinates);

% filtered_trials_T will have the channels as columns

filtered_trials=filtered_trials_T';

end
