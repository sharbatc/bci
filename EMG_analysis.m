function EMG = EMG_analysis(EMG, Fs) 


%% Filters
order=4;

[nChannel N]=size(EMG);

% Band pass
d=fdesign.bandpass('N,F3dB1,F3dB2',order,10, 1000, Fs); % I think there is something wrong here
h=design(d,'butter');
%fvtool(h);
for i=1:nChannel 
EMG(i,:)=filtfilt(h.sosMatrix,h.ScaleValues,EMG(i,:));
end

% High pass
Fh=10;
Fch=2*Fh/Fs;
d=fdesign.highpass('N,Fc',order,Fch);
h=design(d,'butter');

for i=1:nChannel
EMG(i,:)=filtfilt(h.sosMatrix,h.ScaleValues,EMG(i,:));
end

% Low-pass
Fb=30;
Fc=2*Fb/Fs;
d=fdesign.lowpass('N,Fc',order,Fc);
h=design(d,'butter');

for i=1:nChannel
EMG(i,:)=filtfilt(h.sosMatrix,h.ScaleValues,EMG(i,:));
end
% 
EMG =[ EMG(1,:) - EMG(2,:); EMG(3,:) - EMG(4,:)];


%% Rectification
EMG = zscore(EMG);

%% Burst analysis

%% Principal component analysis

end