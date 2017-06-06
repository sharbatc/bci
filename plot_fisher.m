function disc = plot_fisher(orderedPower, orderedInd, name)
% plots the discriminant power (calculated by Fisher score of the channels)
% organize features into a matrix again -> 64*size(PSD) matrix

% init an empty vector and fill in with the values
n = size(orderedInd, 2);
disc_tmp = zeros(1, n);
disc_tmp(orderedInd) = orderedPower;
% reshape matrix (it's a bit messy...)
pxx = disc_tmp(1:end-(64*7)); % 7 is hard coded for 1+6diff bands (see calc_powers.m)
band_powers = disc_tmp(end-(64*7)+1:end); % 7 is hard coded for 1+6diff bands (see calc_powers.m)

disc = [reshape(pxx,[],64)', reshape(band_powers,7,64)'];

figure;
colormap jet;
imagesc(disc);
title(sprintf('%s: Fisher score', name));
xlabel('features');
ylabel('electrodes');
colorbar;
set(gca,'fontsize',15);


fName = sprintf('pictures/%s_disc.png',name);
saveas(gcf, fName);

end