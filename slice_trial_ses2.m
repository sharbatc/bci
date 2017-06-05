function [channels_, eye_channels_, biceps_channels_, trigger_] = slice_trial_ses2(trial, channels, eye_channels, biceps_channels, cleared_trigger_ses2)
% cuts out 1 trial from the recording

assert((1 <= trial) && (trial <= 15), 'trial number should be between 1 and 15');

starts = find(cleared_trigger_ses2==1);
stops = find(cleared_trigger_ses2==255);
start = starts(trial);
stop = stops(trial);

channels_ = channels(:,start:stop);
eye_channels_ = eye_channels(:,start:stop);
biceps_channels_ = biceps_channels(:,start:stop);
trigger_ = cleared_trigger_ses2(1,start:stop);

sprintf('trial:%i loaded', trial);

end