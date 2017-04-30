function [channels_, eye_channels_, biceps_channels_, trigger_] = slice_trial(trial, channels, eye_channels, biceps_channels, trigger)
% cuts out 1 trial from the recording

assert((1 <= trial) && (trial <= 15), 'trial number should be between 1 and 15');

starts = find(cleaned_trigger==1);
stops = find(cleaned_trigger==255);
start = starts(trial);
stop = stops(trial);

channels_ = channels(:,start:stop);
eye_channels_ = eye_channels(:,start:stop);
biceps_channels_ = biceps_channels(:,start:stop);
trigger_ = trigger(1,start:stop);

sprintf('trial:%i loaded', trial);

end