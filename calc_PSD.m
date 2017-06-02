function [pxx, f] = calc_PSD(channels, Fs)
% calculates Power Spectrum Density

%[pxx_T,f_T] = periodogram(channels',[],[],Fs);
%f = f_T';
%pxx = 10*log10(pxx_T');


segment = Fs;
noverlap = 0;
[pxx_T,f_T] = pwelch(channels',segment,noverlap,[],Fs);
f = f_T';
pxx = 10*log10(pxx_T');

end
