function y = mean2(x) %#codegen
%MEAN2 Average or mean of matrix elements.
%   B = MEAN2(A) computes the mean of the values in A.
%
%   Class Support
%   -------------
%   A can be numeric or logical. B is a scalar of class single if A is
%   single and double otherwise.
%
%   Example
%   -------
%       I = imread('liftingbody.png');
%       val = mean2(I)
%  
%   See also MEAN, STD, STD2.

%   Copyright 1993-2016 The MathWorks, Inc.

y = sum(x(:),'default') / numel(x);
