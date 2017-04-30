function [header, channels, eye_channels, biceps_channels, cleared_trigger] = initialize(fName)

% load in data
eeg1 = readbdfheader(fName);
[signal, header] = readbdfdata(eeg1);

% keep only the relevant channels
channels = signal(1:64,:);
eye_channels = signal(65:67,:);
biceps_channels = signal(68:71,:);
trigger = signal(end,:);
cleared_trigger = clear_trigger(trigger);
print_trigger_info(cleared_trigger);


end