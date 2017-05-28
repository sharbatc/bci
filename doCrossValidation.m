function positive_rates = doCrossValidation (labels, areas)

positive_rates = struct();
positive_rates.areas = areas;
positive_rates.labels = labels;

positive_rates.train = struct();
positive_rates.test = struct();


classification_type = cellstr(['diaglinear   ';
                               'linear       ';
                               'diagquadratic';
                               'quadratic    ';
                               'Naive Bayes  ';
                               'SVM          ';
                               ]);

positive_rates.classification_type = classification_type;

cp = cvpartition(labels, 'kfold', 10);


% do cross validation for each classification type
for i=1:size(classification_type,1)
    classifiertype1 = char(classification_type(i));
    disp(classifiertype1)

    
    % Naive Bayes classification
    if size(classifiertype1,2)==11 & classifiertype1=='Naive Bayes'
        for j=1:10

            train_features = areas(cp.training(j), :);
            train_labels = labels(cp.training(j),:);
            test_features = areas(cp.test(j),:);
            test_labels = labels(cp.test(j),:);
            
            classifier = fitcnb(train_features, train_labels);
            
            train_res = predict(classifier, train_features); 
            C_train = confusionmat(train_labels,train_res);
            % TRAIN - TRUE POSITIVE RATE
            positive_rates.train.true_pos_rate_easy(i,j)=C_train(1,1)/sum(C_train(1,:));
            positive_rates.train.true_pos_rate_medium(i,j)=C_train(2,2)/sum(C_train(2,:));
            positive_rates.train.true_pos_rate_hard(i,j)=C_train(3,3)/sum(C_train(3,:));
            % TRAIN - FALSE POSITIVE RATE
            positive_rates.train.false_pos_rate_easy(i,j)=sum(C_train(2:3,1))/sum(sum(C_train(2:3,:)));
            positive_rates.train.false_pos_rate_medium(i,j)=sum(C_train([1 3],2))/sum(sum(C_train([1 3],:)));
            positive_rates.train.false_pos_rate_hard(i,j)=sum(C_train(1:2,3))/sum(sum(C_train(1:2,:)));
            % TRAINING ERROR
            positive_rates.train.classerror(i,j) = classerror(train_res, train_labels);

            
            test_res = predict(classifier, test_features); 
            C_train = confusionmat(test_labels,test_res);
            % TEST - TRUE POSITIVE RATE
            positive_rates.test.true_pos_rate_easy(i,j)=C_train(1,1)/sum(C_train(1,:));
            positive_rates.test.true_pos_rate_medium(i,j)=C_train(2,2)/sum(C_train(2,:));
            positive_rates.test.true_pos_rate_hard(i,j)=C_train(3,3)/sum(C_train(3,:));
            % TEST - FALSE POSITIVE RATE
            positive_rates.test.false_pos_rate_easy(i,j)=sum(C_train(2:3,1))/sum(sum(C_train(2:3,:)));
            positive_rates.test.false_pos_rate_medium(i,j)=sum(C_train([1 3],2))/sum(sum(C_train([1 3],:)));
            positive_rates.test.false_pos_rate_hard(i,j)=sum(C_train(1:2,3))/sum(sum(C_train(1:2,:)));
            % TEST ERROR
            positive_rates.test.classerror(i,j) = classerror(test_res, test_labels);
            
            

        end
    
    %SVM classification 
    elseif size(classifiertype1,2)==3 & classifiertype1=='SVM'
        for j=1:10

            train_features = areas(cp.training(j), :);
            train_labels = labels(cp.training(j),:);
            test_features = areas(cp.test(j),:);
            test_labels = labels(cp.test(j),:);
            
            classifier = fitcecoc(train_features, train_labels);
            
            train_res = predict(classifier, train_features); 
            C_train = confusionmat(train_labels,train_res);
            % TRAIN - TRUE POSITIVE RATE
            positive_rates.train.true_pos_rate_easy(i,j)=C_train(1,1)/sum(C_train(1,:));
            positive_rates.train.true_pos_rate_medium(i,j)=C_train(2,2)/sum(C_train(2,:));
            positive_rates.train.true_pos_rate_hard(i,j)=C_train(3,3)/sum(C_train(3,:));
            % TRAIN - FALSE POSITIVE RATE
            positive_rates.train.false_pos_rate_easy(i,j)=sum(C_train(2:3,1))/sum(sum(C_train(2:3,:)));
            positive_rates.train.false_pos_rate_medium(i,j)=sum(C_train([1 3],2))/sum(sum(C_train([1 3],:)));
            positive_rates.train.false_pos_rate_hard(i,j)=sum(C_train(1:2,3))/sum(sum(C_train(1:2,:)));
            % TRAINING ERROR
            positive_rates.train.classerror(i,j) = classerror(train_res, train_labels);

            
            test_res = predict(classifier, test_features); 
            C_train = confusionmat(test_labels,test_res);
            % TEST - TRUE POSITIVE RATE
            positive_rates.test.true_pos_rate_easy(i,j)=C_train(1,1)/sum(C_train(1,:));
            positive_rates.test.true_pos_rate_medium(i,j)=C_train(2,2)/sum(C_train(2,:));
            positive_rates.test.true_pos_rate_hard(i,j)=C_train(3,3)/sum(C_train(3,:));
            % TEST - FALSE POSITIVE RATE
            positive_rates.test.false_pos_rate_easy(i,j)=sum(C_train(2:3,1))/sum(sum(C_train(2:3,:)));
            positive_rates.test.false_pos_rate_medium(i,j)=sum(C_train([1 3],2))/sum(sum(C_train([1 3],:)));
            positive_rates.test.false_pos_rate_hard(i,j)=sum(C_train(1:2,3))/sum(sum(C_train(1:2,:)));
            % TEST ERROR
            positive_rates.test.classerror(i,j) = classerror(test_res, test_labels);

        end
        
    % all the other classifications
    else
        for j=1:10

            train_features = areas(cp.training(j), :);
            train_labels = labels(cp.training(j),:);
            test_features = areas(cp.test(j),:);
            test_labels = labels(cp.test(j),:);
            
            classifier = fitcdiscr(train_features, train_labels, 'discrimtype',  classifiertype1, 'ClassNames', [0 1 2]);
            
            train_res = predict(classifier, train_features);
            C_train = confusionmat(train_labels,train_res);
            % TRAIN - TRUE POSITIVE RATE
            positive_rates.train.true_pos_rate_easy(i,j)=C_train(1,1)/sum(C_train(1,:));
            positive_rates.train.true_pos_rate_medium(i,j)=C_train(2,2)/sum(C_train(2,:));
            positive_rates.train.true_pos_rate_hard(i,j)=C_train(3,3)/sum(C_train(3,:));
            % TRAIN - FALSE POSITIVE RATE
            positive_rates.train.false_pos_rate_easy(i,j)=sum(C_train(2:3,1))/sum(sum(C_train(2:3,:)));
            positive_rates.train.false_pos_rate_medium(i,j)=sum(C_train([1 3],2))/sum(sum(C_train([1 3],:)));
            positive_rates.train.false_pos_rate_hard(i,j)=sum(C_train(1:2,3))/sum(sum(C_train(1:2,:)));
            
            
            % TRAINING ERROR
            positive_rates.train.classerror(i,j) = classerror(train_res, train_labels);

            
            test_res = predict(classifier, test_features);
            C_train = confusionmat(test_labels,test_res);
            % TEST - TRUE POSITIVE RATE
            positive_rates.test.true_pos_rate_easy(i,j)=C_train(1,1)/sum(C_train(1,:));
            positive_rates.test.true_pos_rate_medium(i,j)=C_train(2,2)/sum(C_train(2,:));
            positive_rates.test.true_pos_rate_hard(i,j)=C_train(3,3)/sum(C_train(3,:));
            % TEST - FALSE POSITIVE RATE
            positive_rates.test.false_pos_rate_easy(i,j)=sum(C_train(2:3,1))/sum(sum(C_train(2:3,:)));
            positive_rates.test.false_pos_rate_medium(i,j)=sum(C_train([1 3],2))/sum(sum(C_train([1 3],:)));
            positive_rates.test.false_pos_rate_hard(i,j)=sum(C_train(1:2,3))/sum(sum(C_train(1:2,:)));
            
            
            % TEST ERROR
            positive_rates.test.classerror(i,j) = classerror(test_res, test_labels);

        end
    
    end

end

% organize the data

rates = {'true_pos_rate_easy', 'true_pos_rate_medium', 'true_pos_rate_hard', 'false_pos_rate_easy', 'false_pos_rate_medium', 'false_pos_rate_hard'};
%trying to make it less messy

for i=1:3
    
    [val,ind] = sort(positive_rates.train.(rates{i+3})');
    positive_rates.train.(rates{i+3}) = val';
    for j=1:size(ind,2)
        ind(:,j)=10*(j-1)+ind(:,j);         % as much indexes as the size of the matrix
    end
    positive_rates.train.(rates{i}) = positive_rates.train.(rates{i})';
    positive_rates.train.(rates{i}) = positive_rates.train.(rates{i})(ind);
    positive_rates.train.(rates{i}) = positive_rates.train.(rates{i})';
    
    [val,ind] = sort(positive_rates.test.(rates{i+3})');
    positive_rates.test.(rates{i+3}) = val';
    for j=1:size(ind,2)
        ind(:,j)=10*(j-1)+ind(:,j);         % as much indexes as the size of the matrix
    end
    positive_rates.test.(rates{i}) = positive_rates.test.(rates{i})';
    positive_rates.test.(rates{i}) = positive_rates.test.(rates{i})(ind);
    positive_rates.test.(rates{i}) = positive_rates.test.(rates{i})';

end





end