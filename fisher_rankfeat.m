function [orderedPower, orderedInd] = fisher_rankfeat(data, label)
% updated version of Data Analysis TA's rankfeat.m (implements only Fisher score)

nFeature = size(data, 2);
S = zeros(1,nFeature);
u_i = mean(data);  %Mean of each feature
classLabels = unique(label);
nClass = length(classLabels);

for iFeature = 1:nFeature
	n_j = zeros(1,nClass);
	u_ij = zeros(1,nClass);
	sigma_ij = zeros(1,nClass);
	for jClass = 1:nClass
        n_j(jClass) = sum(label == classLabels(jClass));
        u_ij(jClass) = mean(data(label == classLabels(jClass),iFeature));
        sigma_ij(jClass) = var(data(label == classLabels(jClass),iFeature));
	end
	S(iFeature) = sum(n_j.*(u_ij-u_i(iFeature)).^2)/sum(n_j.*sigma_ij);
end

[orderedPower, orderedInd] = sort(S,'descend');

end
