function plot_PSD(labels, features, f, name)
% plots out some random PSD for all channels (both easy and hard)

len_PSD = size(features,2)/64;
assert(len_PSD == size(f,2), 'calculated PSD length and the length of the freq. vector do not match');

% get 10 random easy trials 
idx_easy = find(labels == 0)';
rnd_sample_easy = datasample(idx_easy, 10, 'Replace', false);
rnd_features_easy = features(rnd_sample_easy,:);

% get 10 random hard trials 
idx_hard = find(labels == 1)';
rnd_sample_hard = datasample(idx_hard, 10, 'Replace', false);
rnd_features_hard = features(rnd_sample_hard,:);

for c=0:63  % iterates over every channel (1 figure will be saved for all channels)
	figure;
    set(gcf,'units','points','position',[100,100,1000,800])
	pxx_easy = rnd_features_easy(:,(c*len_PSD)+1:(c+1)*len_PSD);
    pxx_hard = rnd_features_hard(:,(c*len_PSD)+1:(c+1)*len_PSD);
    for i=1:10  % iterates over 10 random sample (easy + hard)
        plot(f,pxx_easy(i,:),'b-','LineWidth',0.5);
        hold on;
        plot(f,pxx_hard(i,:),'r-','LineWidth',0.5);
        hold on;
    end
    avg_easy = plot(f,mean(pxx_easy,1),'b-','LineWidth',2,'DisplayName','mean(easy)');
    hold on;
    avg_hard = plot(f,mean(pxx_hard,1),'r-','LineWidth',2,'DisplayName','mean(hard)');
    legend([avg_easy, avg_hard],{'mean(easy)','mean(hard)'});
    title(sprintf('%s electrode:%i',name,c+1));
    xlabel('freq (Hz)');
    xlim([0,49]);
    ylabel('pxx (dB)');
    fName = sprintf('pictures/%s_el_%i.png',name,c+1);
	saveas(gcf, fName)
end

end