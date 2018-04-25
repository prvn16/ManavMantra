function covarianceReducer(~,intermValIter,outKVStore)
%covarianceReducer Reducer function for mapreduce to compute covariance

% Copyright 2014 The MathWorks, Inc.

% We will combine results computed in the mapper for different chunks of
% the data, updating the count, mean, and covariance each time we add a new
% chunk.

% First, initialize everything to zero (scalar 0 is okay)
n1 = 0; % no rows so far
m1 = 0; % mean so far
c1 = 0; % covariance so far

while hasnext(intermValIter)
    % Get the next chunk, and extract the count, mean, and covariance
    t = getnext(intermValIter);
    n2 = t{1};
    m2 = t{2};
    c2 = t{3};
    
    % Use weighting formulas to update the values so far
    n = n1+n2;                     % new count
    m = (n1*m1 + n2*m2) / n;       % new mean
    
    % New covariance is a weighted combination of the two covariance, plus
    % additional terms that relate to the difference in means
    c1 = (n1*c1 + n2*c2 + n1*(m1-m)'*(m1-m) + n2*(m2-m)'*(m2-m))/ n;
    
    % Store the new mean and count for the next iteration
    m1 = m;
    n1 = n;
end

% Save results in the output key/value store
add(outKVStore,'count',n1);
add(outKVStore,'mean',m1);
add(outKVStore,'cov',c1);
end