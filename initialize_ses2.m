function [header, channels, eye_channels, biceps_channels, cleared_trigger_ses2] = initialize_ses2(fName,down_)

% load in data
eeg1 = readbdfheader(fName);
[signal, header] = readbdfdata(eeg1);

% keep only the relevant channels
channels = signal(1:64,:);
eye_channels = signal(65:67,:);
biceps_channels = signal(68:71,:);
trigger = signal(end,:);
cleared_trigger_ses2 = clear_trigger_ses2(trigger,down_);
print_trigger_info_ses2(cleared_trigger_ses2);


end