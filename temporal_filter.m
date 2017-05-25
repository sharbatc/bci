function filtered_channels = temporal_filter(channels, Fs)
% temporal filtering of the signal 
% (girls' code replaced by Andras's butter filter code...)

D = designfilt('bandpassiir','FilterOrder',20,'HalfPowerFrequency1',1,'HalfPowerFrequency2',45,'SampleRate',Fs,'DesignMethod','butter');
%display the filter:
%fvtool(D,'MagnitudeDisplay','zero-phase','Fs',Fs)

filtered_channels = filter(D,channels);

end
