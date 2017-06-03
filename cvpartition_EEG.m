function cp = cvpartition_EEG(labels,nfolds)
% replace partitioning with cont. samples (the signal is non-stationary)
% input labels: has to be column vector with 2 unique labels

class_labels = unique(labels);
idx_class1 = find(labels == class_labels(1));
idx_class2 = find(labels == class_labels(2));
assert(size(idx_class1,1) + size(idx_class2,1) == size(labels,1), 'implemented only for 2 class!');

% this will reject some elements... (it's way easier to implement it like this)
nclass1 = floor(size(idx_class1,1)/nfolds)*nfolds;
idx_class1 = idx_class1(1:nclass1,1);
class1 = reshape(idx_class1',nfolds,[]);
% this will reject some elements... (it's way easier to implement it like this)
nclass2 = floor(size(idx_class2,1)/nfolds)*nfolds;
idx_class2 = idx_class2(1:nclass2,1);
class2 = reshape(idx_class2',nfolds,[])';

% init partitioning
cp = struct('test',zeros(nfolds,size(class1,2)+size(class2,2)),...
            'training',zeros(nfolds,(size(class1,2)+size(class2,2))*(nfolds-1)));
% fill in partitions
tmp = linspace(1,nfolds,nfolds);
for i=1:nfolds
    cp.test(i,:) = [class1(i,:), class2(i,:)];
    cp.training(i,:) = [reshape(class1(setdiff(tmp,i),:)',1,[]),...
                        reshape(class2(setdiff(tmp,i),:)',1,[])];
end
        
assert(isempty(find(cp.test == 0))==1 & isempty(find(cp.test == 0))==1, 'error in partitioning')

end