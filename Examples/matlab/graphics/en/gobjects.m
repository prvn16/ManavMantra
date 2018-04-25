%GOBJECTS    Return a default graphics object array.
%   GOBJECTS(N) returns a N-by-N matrix of default graphics objects. 
%
%   GOBJECTS(M,N) or GOBJECTS([M,N]) returns a M-by-N matrix of 
%   default graphics objects.
%
%   GOBJECTS(M,N,P,...) or GOBJECTS([M,N,P ...]) returns a 
%   M-by-N-by-P-by-... array of default graphics objects.
%
%   GOBJECTS(SIZE(A)) creates an array of default graphics objects 
%   and is the same size as A.
%
%   GOBJECTS with no arguments creates a 1-by-1 scalar default graphics 
%   object.
%
%   GOBJECTS(0) with input of zero creates a 0-by-0 empty default graphics 
%   object array.
%
%   Note: The size inputs M, N, and P... should be nonnegative integers. 
%   Negative integers are treated as 0, and non-integers are truncated. 
%
%   Example:
%      x = gobjects(2,3)      returns a 2-by-3 default graphics object array
%      x = gobjects([1,2,3])  returns a 1-by-2-by-3 default graphics object array
%
%   See also ZEROS , ONES

%   Copyright 1984-2012 The MathWorks, Inc.
