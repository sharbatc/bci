function auc = calculateAUC(positive_rates)

auc=struct();

rates = {'true_pos_rate_easy', 'true_pos_rate_medium', 'true_pos_rate_hard', 'false_pos_rate_easy', 'false_pos_rate_medium', 'false_pos_rate_hard'};%trying to make it less messy
difficulty = {'easy', 'medium', 'hard'};

for i=1:3
    for j=1:6
        auc.train.(difficulty{i})(j,:)=trapz([0 positive_rates.train.(rates{i+3})(j,:) 1]',[0 positive_rates.train.(rates{i})(j,:) 1]');
        auc.test.(difficulty{i})(j,:)=trapz([0 positive_rates.test.(rates{i+3})(j,:) 1]',[0 positive_rates.test.(rates{i})(j,:) 1]');
    end
end

end