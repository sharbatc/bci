function plotPositiveRates(positive_rates)

rates = {'true_pos_rate_easy', 'true_pos_rate_medium', 'true_pos_rate_hard', 'false_pos_rate_easy', 'false_pos_rate_medium', 'false_pos_rate_hard'};%trying to make it less messy
difficulty = {'easy', 'medium', 'hard'};

zero_vec=zeros(6,1);
one_vec=ones(6,1);

for i=1:3

    % plot for train
    figure
    plot([zero_vec positive_rates.train.(rates{i+3}) one_vec]',[zero_vec positive_rates.train.(rates{i}) one_vec]','LineWidth',1)
    xlabel('false positive rate')
    ylabel('true positive rate')
    xlim([0 1])
    ylim([0 1])
    legend('diaglinear','linear','diagquadratic','quadratic','Naive Bayes','SVM')
    title(sprintf('Plotting of the ROC curve for the %s trial - training sets', difficulty{i}))

    % plot for test
    figure
    plot([zero_vec positive_rates.test.(rates{i+3}) one_vec]',[zero_vec positive_rates.test.(rates{i}) one_vec]','LineWidth',1)
    xlabel('false positive rate')
    ylabel('true positive rate')
    xlim([0 1])
    ylim([0 1])
    legend('diaglinear','linear','diagquadratic','quadratic','Naive Bayes','SVM')
    title(sprintf('Plotting of the ROC curve for the %s trial - test sets', difficulty{i}))


end


end

