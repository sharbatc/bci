function relative_powers = calc_powers(f, pxx)
% calculate relative power of some interesting frequency band in the spectrum

assert(size(pxx,2) == size(f,2), 'calculated PSD length and the length of the freq. vector do not match');

power = trapz(pxx,2);  % integral of the whole power spectrum

% delta wave (2-4 Hz)
pxx_tmp = pxx(:, find(2<=f & f<=4));
power_delta = trapz(pxx_tmp,2);
% theta wave (4-8 Hz)
pxx_tmp = pxx(:, find(4<f & f<=8));
power_theta = trapz(pxx_tmp,2);
% aplha wave (8-13 Hz)
pxx_tmp = pxx(:, find(8<f & f<=13));
power_alpha = trapz(pxx_tmp,2);
% low beta wave (13-18 Hz)
pxx_tmp = pxx(:, find(13<f & f<=18));
power_low_beta = trapz(pxx_tmp,2);
% high beta wave (18-30 Hz)
pxx_tmp = pxx(:, find(18<f & f<=30));
power_high_beta = trapz(pxx_tmp,2);
% gamma wave (30-50 Hz)
pxx_tmp = pxx(:, find(30<f & f<=45));
power_gamma = trapz(pxx_tmp,2);

relative_powers = [power,...
                   power_delta./power, power_theta./power,...
                   power_alpha./power, power_low_beta./power,...
                   power_high_beta./power, power_gamma./power];

end