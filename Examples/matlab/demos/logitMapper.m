function logitMapper(b,t,~,intermKVStore)
%logitMapper Mapper function for mapreduce to perform logistic regression.

% Copyright 2014 The MathWorks, Inc.

% Get data input table and remove any rows with missing values
y = t.ArrDelay;
x = t.Distance;
t = ~isnan(x) & ~isnan(y);
y = y(t)>20;                 % late by more than 20 min
x = x(t)/1000;               % distance in thousands of miles

% Compute the linear combination of the predictors, and the estimated mean
% probabilities, based on the coefficients from the previous iteration
if ~isempty(b)
    % Compute xb as the linear combination using the current coefficient
    % values, and derive mean probabilities mu from them
    xb = b(1)+b(2)*x;
    mu = 1./(1+exp(-xb));
else
    % This is the first iteration. Compute starting values for mu that are
    % 1/4 if y=0 and 3/4 if y=1. Derive xb values from them.
    mu = (y+.5)/2;
    xb = log(mu./(1-mu)); 
end

% To perform weighted least squares, compute a sum of squares and cross
% products matrix:
%      (X'*W*X) = (X1'*W1*X1) + (X2'*W2*X2) + ... + (Xn'*Wn*Xn),
% where X = [X1;X2;...;Xn]  and  W = [W1;W2;...;Wn].
%
% The mapper receives one chunk at a time and computes one of the terms on
% the right hand side. The reducer adds all of the terms to get the
% quantity on the left hand side, and then performs the regression.
w = (mu.*(1-mu));                  % weights
z = xb + (y - mu) .* 1./w;         % adjusted response

X = [ones(size(x)),x,z];           % matrix of unweighted data
wss = X' * bsxfun(@times,w,X);     % weighted cross-products X1'*W1*X1

% Store the results for this part of the data.
add(intermKVStore, 'key', wss);
