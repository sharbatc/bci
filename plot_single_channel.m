function plot_single_channel(chan, f, pxx, Fs)
% plots 1 single channel - trace + PSD

len = size(chan, 2);
t = linspace(0,len/Fs,len);

figure;

subplot(3,1,1);
plot(t, chan, 'Linewidth',2)
title('Voltage measured')
xlim([0,len/Fs]);
xlabel('time (s)')
ylabel('V [mV]')

subplot(3,1,2);
plot(t, chan, 'Linewidth',2)
title('Voltage measured (zoomed first 5s)')
xlim([0,5]);
xlabel('time (s)')
ylabel('V [mV]')

subplot(3,1,3);
plot(f, 10*log10(pxx), 'Linewidth',2);
title('Power Spectrum Density')
xlim([0,50]);
xlabel('freq [Hz]');
ylabel('PSD [dB]');

end