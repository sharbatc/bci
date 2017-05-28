function [train_err, test_err, C_train, C_test] = train_NB(test, train, labels_test, labels_train)
% trains naive Bayes classifier

classifier = fitcnb(train, labels_train);  % train calssifier
yhat = predict(classifier, test);  % predict test set labels

% calc_errors & conf. matrix
train_err = classerror(labels_train, predict(classifier, train));
C_train = confusionmat(labels_train, predict(classifier, train));  % not used so far, but return it any way...
test_err = classerror(labels_test, yhat);
C_test = confusionmat(labels_test, yhat);

end