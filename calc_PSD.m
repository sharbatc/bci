function [pxx, f] = calc_PSD(channels, Fs)
% calculates Power Spectrum Density

[pxx_T,f_T] = periodogram(channels',[],256,Fs);  % 256 is optimized for 1sec epochs (below 50Hz)!
f = f_T';
pxx = 10*log10(pxx_T');

end
