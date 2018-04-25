function [S,L] = bounds(A,in2,in3)
%BOUNDS Smallest and largest elements
%   [S,L] = bounds(A)
%   [S,L] = bounds(A,DIM)
%   [S,L] = bounds(...,NANFLAG)
%
%   See also BOUNDS, TALL.

%   Copyright 2017 The MathWorks, Inc.

if nargin <= 1
    S = min(A);
    L = max(A);
elseif nargin == 2
    S = min(A,[],in2);
    L = max(A,[],in2);
else
    S = min(A,[],in2,in3);
    L = max(A,[],in2,in3);
end
end