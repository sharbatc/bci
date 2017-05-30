function [train_err, test_err, C_train, C_test, ROC_x, ROC_y, AUC] = train_NB(test, train, labels_test, labels_train)
% trains naive Bayes classifier

classifier = fitcnb(train, labels_train);  % train calssifier
[yhat,scores] = predict(classifier, test);  % predict test set labels

% calc_errors, conf. matrix, ROC
train_err = classerror(labels_train, predict(classifier, train));
C_train = confusionmat(labels_train, predict(classifier, train));  % not used so far, but return it any way...
test_err = classerror(labels_test, yhat);
C_test = confusionmat(labels_test, yhat);

[ROC_x,ROC_y,~,AUC] = perfcurve(labels_test,scores(:,2), 1);

% check linearly separable data, and 3 point ROC curve
tmp = size(labels_test,1)+1;
if size(ROC_x,1) ~= tmp
    ROC_x = linspace(0,1,tmp)';
    ROC_y = ones(tmp,1);
    ROC_y(1) = 0;
end

end