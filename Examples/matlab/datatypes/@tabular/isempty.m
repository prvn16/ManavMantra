function tf = isempty(t)
%ISEMPTY True for empty table.
%   TF = ISEMPTY(T) returns logical 1 (true) if T is an empty table and logical 0
%   (false) otherwise.  An empty array has no elements, that is PROD(SIZE(T))==0.
%  
%   See also SIZE.

%   Copyright 2012-2016 The MathWorks, Inc. 

tf = (t.rowDim.length == 0) || (t.varDim.length == 0);
