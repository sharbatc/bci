% cd /Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/BCI_data/
% eeg1 = readbdfheader('ag1_22032017.bdf');
% [a,b] = readbdfdata(eeg1);

cd 'C:\Users\Mariana\Desktop\Ficheiros\erasmus cadeiras\Brain-Computer Interaction\project\Measurments'
load('for_mariana2.mat')


%% FFT 
%Visualize the signal
S = size(a);
L = S(2);             % Length of signal
eeg_sig=a(1:64,:);
time=0:L-1;
time=time/2048;
figure
plot(time,eeg_sig(48,:))  %plot Cz channel
xlabel('time(s)')
ylabel('channel Cz')

% FFT of the channel
cz_fft = fft(eeg_sig(48,:));
Fs = 2048;            % Sampling frequency                    
T = 1/Fs;             % Sampling period   
t = (0:L-1)*T;        % Time vector

P2 = abs(cz_fft/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
figure
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of S(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%% BP Filter

%2048 Hz sampling rate
% I love my teammates sooo much
D = designfilt('bandpassiir','FilterOrder',20, 'HalfPowerFrequency1',0.5,'HalfPowerFrequency2', 40, 'SampleRate',2048);
filtered_signal = filter(D, a(1:64,:)); 

% plot filtered signal
S = size(a);
L = S(2);                           % Length of signal
time=0:L-1;
time=time/2048;

figure
plot(time,filtered_signal(48,:))    %plot Cz channel
xlabel('time(s)')
ylabel('channel Cz')
xlim([200,205])

% FFT of the filtered signal
cz_fft = fft(filtered_signal);
Fs = 2048;                          % Sampling frequency                    
T = 1/Fs;                           % Sampling period   
t = (0:L-1)*T;                      % Time vector

P2 = abs(cz_fft(48,:)/L);           % Plot fourier transform of channel cz
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
figure
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of S(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')



%% SPATIAL FILTER

chanfile = '10-20_biosemi.txt'; % absolute or relative path
capsize = 58; % cm
laplaciansize = 5; % cm
electrodes = 1:64;

% datain -> (time_points, channels)

coordinates = proc_coordinates(chanfile, capsize, laplaciansize, electrodes);
[dataout, mask, layout] = proc_lap(filtered_signal', coordinates);

% Compare signals with and without spacial filtering
figure
plot(time,filtered_signal)  %plot Cz channel filtered temporally
xlabel('time(s)')
ylabel('channel Cz')
%xlim([200,205])

figure
dataout1= dataout';
plot(time,dataout1(48,:))  %plot Cz channel filtered temporally and spacially
xlabel('time(s)')
ylabel('channel Cz')
%xlim([200,205])




