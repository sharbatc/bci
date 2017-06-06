function behav_analysis(data,name)

switch name
    case 'Andras'
        addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Andras22032017');
        quest = readtext('ag2_22032017_questionnaire.csv');
        labels = [0,2,0,1,2,2,0,0,0,1,1,1,2,2,1]; % Andras' 1st

    case 'Mariana'
        addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Mariana1332017');
        quest= readtext('ad10_13032017_questionnaire.csv');
        labels = [0,2,0,0,2,0,2,2,1,1,1,1,2,1,0]; % Mariana's 1st
 
    case 'Sharbat'
        addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Sharbath8032017');
        quest = readtext('questionaire_08032017.csv');
        labels = [0,0,0,1,1,2,2,2,0,0,1,2,1,1,2]; % Sharbat's 1st

    case 'Elisabetta'
        addpath('/Users/elisabettamessina/Desktop/EPFL2sem/bci/BCI_project/Group_AMES/1_Elisabetta220317');
        quest =readtext('ag1_22032017_questionnaire.csv');
        labels = [0,1,2,0,2,0,1,1,2,2,1,0,0,2,1]; % Elisabetta's 1st
end


mat = cell2mat(quest(6:20,:));
legend = char(quest(5,:));

%% Perceived difficulty boxplot
easy_diff = mat(find(labels==0),2);
assisted_diff = mat(find(labels==1),2);
hard_diff = mat(find(labels==2),2);
figure;
boxplot([easy_diff, assisted_diff, hard_diff],'Labels',{'Easy','Hard + assist', 'Hard'});
title(sprintf('%s: Perceived difficulty', name));
set(gca,'fontsize',13);

fName = sprintf('pictures/%s_pdifficulty.png',name);
saveas(gcf, fName);


%% User performance boxplot

easy_missed = [];
easy_passed = [];
assist_passed = [];
assist_missed = [];
hard_missed = [];
hard_passed = [];

trials = {'t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15'}; % stupid MATLAB...
for i=1:15
    if labels(i) == 0
  	easy_passed = [easy_passed; length(find( data.(trials{i}).trigger == 48))];
    easy_missed = [easy_missed;length(find( data.(trials{i}).trigger == 16))];
    elseif labels(i) == 1
    assist_passed = [assist_passed; length(find( data.(trials{i}).trigger == 48))];
    assist_missed = [assist_missed; length(find( data.(trials{i}).trigger == 16))];
    elseif labels(i) == 2
    hard_passed = [hard_passed; length(find( data.(trials{i}).trigger == 48))];
    hard_missed = [hard_missed; length(find( data.(trials{i}).trigger == 16))];
    end
end

easy_succ_rate = easy_passed./(easy_passed+easy_missed);
assist_succ_rate = assist_passed./(assist_passed+assist_missed);
hard_succ_rate = hard_passed./(hard_passed+hard_missed);

figure
boxplot([easy_succ_rate, assist_succ_rate, hard_succ_rate],'Labels',{'Easy','Hard + assist', 'Hard'});
title(sprintf('%s: User performance', name));
set(gca,'fontsize',13);

fName = sprintf('pictures/%s_performance.png',name);
saveas(gcf, fName);


end
