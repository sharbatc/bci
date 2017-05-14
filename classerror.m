function err = classerror(y, yhat)
% adatped from DataAnalysis TA's: conmputes class error
% y-labels, yhat-output of the classifier

classes = unique(y);
err_ = zeros(1,length(classes));

for c=1:length(classes)
    err_(c) = sum((y~=yhat) & (y == classes(c)))./sum(y==classes(c));% + sum((y~=yhat) & (y == 1))./sum(y==1));
end

err = mean(err_);
end

