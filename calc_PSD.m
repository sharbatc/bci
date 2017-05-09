function [pxx, f] = calc_PSD(channels, Fs)
% calculates Power Spectrum Density

[pxx_T,f_T] = periodogram(channels',[],512,Fs);
f = f_T';
pxx = pxx_T';

end
