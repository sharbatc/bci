clear all
close all
clc
%%
% Andras
name = 'Andras';
addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Andras22032017');
quest = readtext('ag2_22032017_questionnaire.csv');
labels = [0,2,0,1,2,2,0,0,0,1,1,1,2,2,1]; % Andras' 1st

% % Mariana
% name = 'Mariana';
% addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Mariana1332017');
% quest= readtext('ad10_13032017_questionnaire.csv');
% labels = [0,2,0,0,2,0,2,2,1,1,1,1,2,1,0]; % Mariana's 1st
%  
% % Sharby
% name = 'Sharbat';
% addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Sharbath8032017');
% quest = readtext('questionnaire_08032017.csv');
% labels = [0,0,0,1,1,2,2,2,0,0,1,2,1,1,2]; % Sharbat's 1st

% % Elisabetta
%name = 'Elisabetta';
% addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Elisabetta220317');
% quest =readtext('ag1_22032017_questionnaire.csv');
%labels = [0,1,2,0,2,0,1,1,2,2,1,0,0,2,1]; % Elisabetta's 1st




%%
mat = cell2mat(quest(6:20,:));
legend = char(quest(5,:));

%Perceived difficulty boxplot
easy_diff = mat(find(labels==0),2);
assisted_diff = mat(find(labels==1),2);
hard_diff = mat(find(labels==2),2);
boxplot([easy_diff, assisted_diff, hard_diff],'Labels',{'Easy','Assisted', 'Hard'});
title(sprintf('Perceived difficulty for %s', name));
ylabel('Perceived difficulty score');



