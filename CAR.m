function filtered_channels = CAR(channels)
filtered_channels = [];
n_channels = size(channels,1);
for i=1:n_channels
    u=channels(i,:);
    u_CAR = u(i)-1/n_channels * sum(channels);
    filtered_channels = [filtered_channels; u_CAR];
end

end