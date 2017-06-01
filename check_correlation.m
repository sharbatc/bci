function [horizontal_corr, vertical_corr] =  check_correlation(channels, eye_channels, down, threshold)
% checks the correlation of the channels with EOG (downsampled and filter EOG first)

% downsample EOG
Fs = 2048/down;
left_eye = eye_channels(1,1:down:end);
nasion = eye_channels(2,1:down:end);
right_eye = eye_channels(3,1:down:end);

% spatial gilter EOG
horizontal_eye_movement = left_eye-right_eye;
vertical_eye_movement = nasion - mean([left_eye; right_eye]);

% temporal filter EOG
horizontal_eye_movement = temporal_filter(horizontal_eye_movement, Fs);
vertical_eye_movement = temporal_filter(vertical_eye_movement, Fs);

eye_movement_corr = zeros(2,64);  % store results
for i=1:64
    chan = channels(i,:);
    % horizontal eye movement (1st row in eye_movement_corr)
    tmp = corrcoef(chan, horizontal_eye_movement); % 2*2 matrix
    corr_ = tmp(1,2);
    eye_movement_corr(1,i) = corr_;
    % vertical eye movement (2nd row in eye_movement_corr)
    tmp = corrcoef(chan, vertical_eye_movement); % 2*2 matrix
    corr_ = tmp(1,2);
    eye_movement_corr(2,i) = corr_;
end

% check for high correlation
horizontal_corr = [];
vertical_corr = [];
[row, col] = find(abs(eye_movement_corr) > threshold);
for i=1:size(row)
    if row(i) == 1
        horizontal_corr = [horizontal_corr, col(i)];
        %fprintf('horizontal eye movement correlation is higher than %2f - chan:%i \n',threshold, col(i));
    elseif row(i) == 2
        vertical_corr = [vertical_corr, col(i)];
        %fprintf('vertical eye movement correlation is higher than %2f chan:%i \n',threshold, col(i));
    end
end

end