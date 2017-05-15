function filtered_channels = temporal_filter(channels, Fs)
% temporal filtering of the signal 
% (girls' code replaced by András's butter filter code...)

D = designfilt('bandpassiir','FilterOrder',20,...
               'HalfPowerFrequency1',0.001,'HalfPowerFrequency2',50,...
               'SampleRate',Fs,'DesignMethod','butter');

filtered_channels = filter(D,channels);

end
