function t = isempty(a)
%ISEMPTY True for empty categorical array.
%   ISEMPTY(X) returns 1 if X is an empty array and 0 otherwise. An
%   empty array has no elements, that is numel(X)==0.
%
%   See also SIZE, NUMEL.

%   Copyright 2006-2013 The MathWorks, Inc. 

t = isempty(a.codes);
