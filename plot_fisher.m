function disc = plot_fisher(orderedPower, orderedInd, name)
% plots the discriminant power (calculated by Fisher score of the channels)
% organize features into a matrix again -> 64*size(PSD) matrix

% init an empty vector and fill in with the values
tmp = zeros(1, size(orderedInd, 2));
tmp(orderedInd) = orderedPower;
% reshape matrix
disc = reshape(tmp,[],64)';

figure;
imagesc(disc);
title('Fisher score')
xlabel('PSD - Freq (Hz)')
ylabel('electrode')
colorbar;

fName = sprintf('pictures/%s_disc.png',name);
saveas(gcf, fName)

end