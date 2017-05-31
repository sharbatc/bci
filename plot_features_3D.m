function plot_features_3D(labels, features_red, name)
% plots the first 3 best feature

assert(size(features_red,2)==3,'Use only 3 features for this plot!');

figure;
scatter3(features_red(find(labels==0),1),features_red(find(labels==0),2),features_red(find(labels==0),3),'b','filled');
hold on;
scatter3(features_red(find(labels==1),1),features_red(find(labels==1),2),features_red(find(labels==1),3),'r','filled');
title(sprintf('%s: Best 3 features', name));
legend('easy', 'hard');

fName = sprintf('pictures/%s_plot3D.png',name);
saveas(gcf, fName);

end