function plot_features_3D(labels, features_red, ses, name)
% plots the first 3 best feature

assert(size(features_red,2)==3,'Use only 3 features for this plot!');

figure;
set(gcf,'units','points','position',[100,100,700,500]);
    
scatter3(features_red(find(labels==0),1),features_red(find(labels==0),2),features_red(find(labels==0),3),'b','filled');
hold on;
scatter3(features_red(find(labels==1),1),features_red(find(labels==1),2),features_red(find(labels==1),3),'r','filled');
title(sprintf('%s: Best 3 features, session:%i', name,ses));
legend('easy', 'hard');
set(gca,'fontsize',15);

fName = sprintf('pictures/s%i_%s_plot3D.png',ses,name);
saveas(gcf, fName);

end