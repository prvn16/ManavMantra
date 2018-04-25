function s = std2(a)
%STD2 Standard deviation of matrix elements.
%   B = STD2(A) computes the standard deviation of the values in
%   gpuArray A.
%
%   Class Support
%   -------------
%   A can be a numeric or logical gpuArray. B is a scalar gpuArray of class
%   single if A is single and double otherwise.
%
%   Example
%   -------
%       I = gpuArray(imread('liftingbody.png'));
%       val = std2(I)
%
%   See also GPUARRAY/CORR2, MEAN2, MEAN, STD, GPUARRAY.

%   Copyright 2013-2016 The MathWorks, Inc.

if isempty(a)
    s = gpuArray(NaN);
    return;
end

n = numel(a);

% convert to column-vector.
a = reshape(a,n,1);

% set up normalization factor and image mean.
norm_factor = 1/(max(n-1,1));

mean_a = sum(a,'default')/n;
if isa(a,'single')
    a = arrayfun(@computeSquaredDifferencesSingle,a);
else
    a = arrayfun(@computeSquaredDifferencesDouble,a);
end

% std is sqrt of sum of normalized square difference from mean.
s = sqrt(norm_factor*sum(a));

%nested function to allow up-level indexing of mean.
function aout = computeSquaredDifferencesDouble(ain)
    % compute squared difference from mean.
    aout = (abs(double(ain)-mean_a))^2; % abs guarantees a real result
end
function aout = computeSquaredDifferencesSingle(ain)
    % compute squared difference from mean.
    aout = (abs(ain-mean_a))^2; % abs guarantees a real result
end
end
