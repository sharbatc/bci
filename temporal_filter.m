function filtered_channels = temporal_filter(channels, Fs)
% temporal filtering of the signal 
% (girls' code replaced by Andr??s's butter filter code...)

%compare signals:
%pwelch(channels(1,:),[],[],[],Fs)
%pwelch(filtererd_channels(1,:),[],[],[],Fs)

%display the filter:
%fvtool(D,'MagnitudeDisplay','zero-phase','Fs',Fs)

D = designfilt('bandpassiir','FilterOrder',20,'HalfPowerFrequency1', 1,'HalfPowerFrequency2',50,'SampleRate',Fs,'DesignMethod','butter');

filtered_channels = filter(D,channels);

end
