function data = save_to_mat_ses2(header, labels, channels, eye_channels, biceps_channels, cleared_trigger_ses2, fName, down_)
% saves the 15 trials into a struct of structs and that to a mat-file -> easier to load in

assert(size(labels,2) == 15, 'Use 15 labels!');

data = struct();
data.header = header;
data.labels = labels;
trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...

for i=1:15
	[channels_, eye_channels_, biceps_channels_, trigger_] = slice_trial_ses2(i, channels, eye_channels, biceps_channels, cleared_trigger_ses2);
    data.(trials{i}).channels = channels_(:,1:down_:end);
    data.(trials{i}).eye_channels = eye_channels_;
    data.(trials{i}).biceps_channels = biceps_channels_;
    trigger_144 = floor(find(trigger_ == 144)/8);
    trigger_176 = floor(find(trigger_ == 176)/8);
    down_trigger = trigger_(:,1:down_:end);
    down_trigger(trigger_144) = 144;
    down_trigger(trigger_176) = 176;
    data.(trials{i}).trigger = down_trigger;
end

% save file
save(fName, 'data');

end