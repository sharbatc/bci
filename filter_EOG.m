function [filtered_EOG] = filter_EOG(eye_channels, down)
% downsample and filter EOG dataset

% downsample EOG
Fs = 2048/down;
left_eye = eye_channels(1,1:down:end);
nasion = eye_channels(2,1:down:end);
right_eye = eye_channels(3,1:down:end);

% spatial filter EOG
horizontal_eye_movement_spatial = left_eye-right_eye;
vertical_eye_movement_spatial = nasion - mean([left_eye; right_eye]);

% temporal filter EOG
horizontal_eye_movement_temp = temporal_filter(horizontal_eye_movement_spatial, Fs);
vertical_eye_movement_temp = temporal_filter(vertical_eye_movement_spatial, Fs);

filtered_EOG = [horizontal_eye_movement_temp; vertical_eye_movement_temp];

end