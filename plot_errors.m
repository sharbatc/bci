function plot_errors(linear, diaglinear, quadratic, diagquadratic, SVM, NB, mode, ses, name, nfolds)
% plot train/test (defined by mode - just naming...) errors after n-fold CV
% keep the order pls!

figure;
set(gcf,'units','points','position',[100,100,700,500]);

grp = [zeros(nfolds,1); ones(nfolds,1); 2*ones(nfolds,1); 3*ones(nfolds,1); 4*ones(nfolds,1); 5*ones(nfolds,1)];
boxplot([linear, diaglinear, quadratic, diagquadratic, SVM, NB], grp,...
        'labels',{'linear', 'diaglinear', 'quadratic', 'diagquadratic', 'SVM', 'Naive Bayes'});
hold on;
plot(xlim,[0.1,0.1],'k--');
title(sprintf('%s: %s errors (%i-fold CV), session:%i',name,mode,nfolds,ses));
ylabel('classerror');
set(gca,'fontsize',15);

fName = sprintf('pictures/s%i_%s_%s_err.png',ses,name,mode);
saveas(gcf, fName);
    
end