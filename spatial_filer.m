function filtered_channels = spatial_filer(channels)
% apply Laplaccian filtering (code from PK, see more in:proc_*.m files)

% spatial organization spec.
chanfile = '10-20_biosemi.txt';
capsize = 58; % cm
laplaciansize = 5; % cm
electrodes = 1:64;

coordinates = proc_coordinates(chanfile, capsize, laplaciansize, electrodes);
[filtered_channels_T, mask, layout] = proc_lap(channels', coordinates);

% transpose output to get back the same structure (channels as rows)
filtered_channels = filtered_channels_T';

end