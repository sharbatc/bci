function plot_ROC(fp_linear, fp_diaglinear, fp_quadratic, fp_diagquadratic, fp_SVM, fp_NB,...
                  tp_linear, tp_diaglinear, tp_quadratic, tp_diagquadratic, tp_SVM, tp_NB, name)
% plots Reciever Operating Characteristic (ROC) curve
% see more: https://en.wikipedia.org/wiki/Receiver_operating_characteristic

AUC = zeros(1,6); % hard coded for 6 input classifier type

figure;
plot(fp_linear, tp_linear,'LineWidth',2);
AUC(1) = trapz(tp_linear);
hold on;
plot(fp_diaglinear, tp_diaglinear,'LineWidth',2);
AUC(2) = trapz(tp_diaglinear);
hold on;
plot(fp_quadratic, tp_quadratic,'LineWidth',2);
AUC(3) = trapz(tp_quadratic);
hold on;
plot(fp_diagquadratic, tp_diagquadratic,'LineWidth',2);
AUC(4) = trapz(tp_diagquadratic);
hold on;
plot(fp_SVM, tp_SVM,'LineWidth',2);
AUC(5) = trapz(tp_SVM);
hold on;
plot(fp_NB, tp_NB,'LineWidth',2);
AUC(6) = trapz(tp_NB);
hold on;
plot([0,1], [0,1], 'k--');
title(sprintf('%s: ROC curve',name))
legend(sprintf('linear AUC: %.3f',AUC(1)),...
       sprintf('diaglinear AUC: %.3f', AUC(2)),...
       sprintf('quadratic AUC: %.3f', AUC(3)),...
       sprintf('diagquadratic AUC: %.3f', AUC(4)),...
       sprintf('SVM AUC: %.3f', AUC(5)),...
       sprintf('Naive Bayes AUC: %.3f', AUC(6)));
xlabel('False positive rate');
xlim([0,1]);
ylabel('True positive rate');
ylim([0,1]);

fName = sprintf('pictures/%s_ROC.png',name);
saveas(gcf, fName);

end
