function [S,L] = bounds(A,in2,in3)
%BOUNDS Smallest and largest elements
%   [S,L] = BOUNDS(A) returns the smallest element S and largest element L
%   found in A. Namely, S = MIN(A) and L = MAX(A).
%
%   [S,L] = BOUNDS(A,DIM) operates along the dimension DIM.
%
%   [S,L] = BOUNDS(...,NANFLAG) also specifies how to treat NaN values.
%   NANFLAG must be:
%       'omitnan'    - (default) Ignores all NaN values and returns the
%                      minimum and maximum of the non-NaN elements.
%       'includenan' - Returns NaN if there is any NaN value.
%
%   See also MIN, MAX, SORT.

%   Copyright 2016 The MathWorks, Inc.

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