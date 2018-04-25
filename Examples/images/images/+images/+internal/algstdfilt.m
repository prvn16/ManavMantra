function J = algstdfilt(I,h)
% Main algorithm used by stdfilt function. See stdfilt for more
% details

% No input validation is done in this function.


% Copyright 2013-2015 The MathWorks, Inc.


n = sum(h(:));

% If n = 1 then return default J (all zeros).
% Otherwise, calculate standard deviation. The formula for standard deviation
% can be rewritten in terms of the theoretical definition of
% convolution. However, in practise, use correlation in IMFILTER to avoid a
% flipped answer when NHOOD is asymmetric.
% conv1 = imfilter(I.^2,h,'symmetric') / (n-1); 
% conv2 = imfilter(I,h,'symmetric').^2 / (n*(n-1));
% std = sqrt(conv1-conv2).  
% These equations can be further optimized for speed.

n1 = n - 1;
if n ~= 1
  conv1 = imfilter(I.^2, h/n1 , 'symmetric');
  conv2 = imfilter(I, h/sqrt(n*n1), 'symmetric').^2;
  J = sqrt(max((conv1 - conv2),0));
else
  J = zeros(size(I));
end
