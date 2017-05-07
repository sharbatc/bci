function power_spectrum = powerSpect (matrix_channels)

% hoping periodogram works, worse case scenario use fft
% the channels must be the columns

power_spectrum=periodogram(matrix_cannels');


end