function plot_PSD(labels, PSD, f, name)
% plots out some random PSD for all channels (both easy and hard)

len_PSD = size(PSD,2)/64;
assert(len_PSD == size(f,2), 'calculated PSD length and the length of the freq. vector do not match');

f_fill = [f, fliplr(f)];  % for shaded plot...

% get 10 random easy trials 
idx_easy = find(labels == 0)';
rnd_sample_easy = datasample(idx_easy, 10, 'Replace', false);
rnd_PSD_easy = PSD(rnd_sample_easy,:);

% get 10 random hard trials 
idx_hard = find(labels == 1)';
rnd_sample_hard = datasample(idx_hard, 10, 'Replace', false);
rnd_PSD_hard = PSD(rnd_sample_hard,:);

for c=0:63  % iterates over every channel (1 figure will be saved for all channels)
	figure('visible', 'off');
    set(gcf,'units','points','position',[100,100,1000,800]);
    
	pxx_easy = rnd_PSD_easy(:,(c*len_PSD)+1:(c+1)*len_PSD);
    min_easy = min(pxx_easy, [], 1);
    max_easy = max(pxx_easy, [], 1);
    easy_fill = [min_easy,fliplr(max_easy)];
    
    pxx_hard = rnd_PSD_hard(:,(c*len_PSD)+1:(c+1)*len_PSD);
	min_hard = min(pxx_hard, [], 1);
    max_hard = max(pxx_hard, [], 1);
    hard_fill = [min_hard,fliplr(max_hard)];
    
	f_easy = fill(f_fill, easy_fill, 'b');
    alpha(f_easy, 0.3);
    set(f_easy,'EdgeColor','none');
    hold on;
    f_hard = fill(f_fill, hard_fill, 'r');
    alpha(f_hard, 0.3);
    set(f_hard,'EdgeColor','none');
    
    avg_easy = plot(f,mean(pxx_easy,1),'b-','LineWidth',2);
    hold on;
    avg_hard = plot(f,mean(pxx_hard,1),'r-','LineWidth',2);
    
    legend([avg_easy, avg_hard],{'mean(easy)','mean(hard)'});
    title(sprintf('%s electrode:%i',name,c+1));
    xlabel('freq (Hz)');
    xlim([2,45]);
    ylabel('pxx (dB)');
    
    fName = sprintf('pictures/PSD/%s_el_%i.png',name,c+1);
	saveas(gcf, fName)
end

end