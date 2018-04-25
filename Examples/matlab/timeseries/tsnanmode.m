function y = tsnanmode(x,dim)
%
% tstool utility function

%   Copyright 2010 The MathWorks, Inc.

if nargin == 1 % let mode figure out which dimension to work along
    y = mode(x);
else           % work along the explicitly given dimension
    y = mode(x,dim);
end
