function [pxx, f] = calc_PSD(channels, Fs)
% calculates Power Spectrum Density

[pxx_T,f_T] = periodogram(channels',[],[],Fs);
f = f_T';
pxx = 10*log10(pxx_T');

end
