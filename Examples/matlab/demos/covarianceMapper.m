function covarianceMapper(t,~,intermKVStore)
%covarianceMapper Mapper function for mapreduce to compute covariance

% Copyright 2014 The MathWorks, Inc.

% Get data from input table and remove any rows with missing values
x = t{:,:};
x = x(~any(isnan(x),2),:);

% Compute and save the count, mean, and covariance
n = size(x,1);
m = mean(x,1);
c = cov(x,1);

% Store these as a single item in the intermediate key/value store
add(intermKVStore,'key',{n m c})
end