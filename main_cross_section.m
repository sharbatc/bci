% corss section validation of the classifiers #ames !

clc;
clear;
close all;

% specification:
name = 'Andras';
ses_data = 2;
ses_classifier = 1;

% load in dataset
fName = sprintf('%s_%i_ML.mat',name,ses_data);
load(fName);
if ses_data == 1
    % replace 2s with 1s in labels (pool hard & hard with assistance)
    labels(labels == 2) = 1;
else
    % remove 1s (medium) from labels and features
    idx = find(labels ~= 1);
    labels = labels(idx);
    features = features(idx,:);
    % replace 2s with 1s in labels
    labels(labels == 2) = 1;
end

test_errors = ones(1,6);
ROC = struct('linear_x',[],'linear_y',[],'diaglinear_x',[],'diaglinear_y',[],...
             'quadratic_x',[],'quadratic_y',[],'diagquadratic_x',[],'diagquadratic_y',[],...
             'SVM_x',[],'SVM_y',[],'NB_x',[],'NB_y',[],'AUCs',zeros(1,6));

% load in pretrained classifiers (linear)
fName = sprintf('classifiers/s%i_%s_linear.mat',ses_classifier, name);
load(fName);
% reorder and slice features
features_reord = features(:,orderedInd);
features_red = features_reord(:,1:keep);
% test classifier
[yhat,scores] = predict(classifier, features_red);
test_errors(1,1) = classerror(labels, yhat);
[ROC.linear_x, ROC.linear_y,~,ROC.AUCs(1,1)] = perfcurve(labels, scores(:,2), 1);

% diaglinear
fName = sprintf('classifiers/s%i_%s_diaglinear.mat',ses_classifier, name);
load(fName);
[yhat,scores] = predict(classifier, features_red);
test_errors(1,2) = classerror(labels, yhat);
[ROC.diaglinear_x, ROC.diaglinear_y,~,ROC.AUCs(1,2)] = perfcurve(labels, scores(:,2), 1);

% quadratic
fName = sprintf('classifiers/s%i_%s_quadratic.mat',ses_classifier, name);
load(fName);
[yhat,scores] = predict(classifier, features_red);
test_errors(1,3) = classerror(labels, yhat);
[ROC.quadratic_x, ROC.quadratic_y,~,ROC.AUCs(1,3)] = perfcurve(labels, scores(:,2), 1);

% diagquadratic
fName = sprintf('classifiers/s%i_%s_diagquadratic.mat',ses_classifier, name);
load(fName);
[yhat,scores] = predict(classifier, features_red);
test_errors(1,4) = classerror(labels, yhat);
[ROC.diagquadratic_x, ROC.diagquadratic_y,~,ROC.AUCs(1,4)] = perfcurve(labels, scores(:,2), 1);

% SVM
fName = sprintf('classifiers/s%i_%s_SVM.mat',ses_classifier, name);
load(fName);
[yhat,scores] = predict(classifier, features_red);
test_errors(1,5) = classerror(labels, yhat);
[ROC.SVM_x, ROC.SVM_y,~,ROC.AUCs(1,5)] = perfcurve(labels, scores(:,2), 1);

% Naive Bays
fName = sprintf('classifiers/s%i_%s_NB.mat',ses_classifier, name);
load(fName);
[yhat,scores] = predict(classifier, features_red);
test_errors(1,6) = classerror(labels, yhat);
[ROC.NB_x, ROC.NB_y,~,ROC.AUCs(1,6)] = perfcurve(labels, scores(:,2), 1);


plot_ROC_cross(ROC.linear_x, ROC.diaglinear_x, ROC.quadratic_x, ROC.diagquadratic_x, ROC.SVM_x, ROC.NB_x,...
               ROC.linear_y, ROC.diaglinear_y, ROC.quadratic_y, ROC.diagquadratic_y, ROC.SVM_y, ROC.NB_y,...
               ses_data, ses_classifier, name, ROC.AUCs);

fprintf('%s: session:%i data, session:%i classifier\ntest error - linear: %f\ntest error - diaglinear: %f\ntest error - quadratic: %f\ntest error - diagquadratic: %f\ntest error - SVM: %f\ntest error - NB: %f\n',...
        name, ses_data, ses_classifier, test_errors(1,1), test_errors(1,2), test_errors(1,3), test_errors(1,4), test_errors(1,5), test_errors(1,6));
