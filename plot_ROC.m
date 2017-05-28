function plot_ROC(fp_linear, fp_diaglinear, fp_quadratic, fp_diagquadratic, fp_SVM, fp_NB,...
                  tp_linear, tp_diaglinear, tp_quadratic, tp_diagquadratic, tp_SVM, tp_NB,name)
% plots Reciever Operating Characteristic (ROC) curve
% see more: https://en.wikipedia.org/wiki/Receiver_operating_characteristic

figure;
[fp_linear, idx] = sort(fp_linear);
scatter(fp_linear, tp_linear(idx), 'filled');
hold on;
[fp_diaglinear, idx] = sort(fp_diaglinear);
scatter(fp_diaglinear, tp_diaglinear(idx), 'filled');
hold on;
[fp_quadratic, idx] = sort(fp_quadratic);
scatter(fp_quadratic, tp_quadratic(idx), 'filled');
hold on;
[fp_diagquadratic, idx] = sort(fp_diagquadratic);
scatter(fp_diagquadratic, tp_diagquadratic(idx), 'filled');
hold on;
[fp_SVM, idx] = sort(fp_SVM);
scatter(fp_SVM, tp_SVM(idx), 'filled');
hold on;
[fp_NB, idx] = sort(fp_NB);
scatter(fp_NB, tp_NB(idx), 'filled');
title(sprintf('%s: ROC curve',name))
legend('linear', 'diaglinear', 'quadratic', 'diagquadratic', 'SVM', 'Naive Bayes');
xlabel('False positive rate');
ylabel('True positive rate');

fName = sprintf('pictures/%s_ROC.png',name);
saveas(gcf, fName);

end
