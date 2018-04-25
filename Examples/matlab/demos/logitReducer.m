function logitReducer(~,intermValIter,outKVStore)
%logitReducer Reducer function for mapreduce to perform logistic regression

% Copyright 2014 The MathWorks, Inc.

% We will operate over chunks of the data, updating the count, mean, and
% covariance each time we add a new chunk
old = 0;

% We want to perform weighted least squares. We do this by computing a sum
% of squares and cross products matrix
%      M = (X'*W*X) = (X1'*W1*X1) + (X2'*W2*X2) + ... + (Xn'*Wn*Xn)
% where X = X1;X2;...;Xn]  and  W = [W1;W2;...;Wn].
%
% The mapper has computed the terms on the right hand side. Here in the
% reducer we just add them up.

while hasnext(intermValIter)
    new = getnext(intermValIter);
    old = old+new;
end
M = old;  % the value on the left hand side

% Compute coefficients estimates from M. M is a matrix of sums of squares
% and cross products for [X Y] where X is the design matrix including a
% constant term and Y is the adjusted response for this iteration. In other
% words, Y has been included as an additional column of X. First we
% separate them by extracting the X'*W*X part and the X'*W*Y part.
XtWX = M(1:end-1,1:end-1);
XtWY = M(1:end-1,end);

% Solve the normal equations.
b = XtWX\XtWY;

% Return the vector of coefficient estimates.
add(outKVStore, 'key', b);