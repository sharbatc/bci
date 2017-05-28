function [train_err, test_err, C_train, C_test] = train_SVM(test, train, labels_test, labels_train)
% trains support vector machine

labels_train(find(labels_train==0)) = -1; % change 0 to -1 for SVM!
labels_test(find(labels_test==0)) = -1; % change 0 to -1 for SVM!

opts = statset('UseParallel',true);  % use paralell pool

classifier = fitcecoc(train, labels_train, 'Options', opts);  % train calssifier
yhat = predict(classifier, test);  % predict test set labels

% calc_errors & conf. matrix
train_err = classerror(labels_train, predict(classifier, train));
C_train = confusionmat(labels_train, predict(classifier, train));  % not used so far, but return it any way...
test_err = classerror(labels_test, yhat);
C_test = confusionmat(labels_test, yhat);

end