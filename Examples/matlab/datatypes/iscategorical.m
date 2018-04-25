function tf = iscategorical(t)
%ISCATEGORICAL True for categorical arrays.
%   ISCATEGORICAL(C) returns logical 1 (true) if C is a categorical array
%   and logical 0 (false) otherwise.
%
%   See also CATEGORICAL, ISNUMERIC, ISOBJECT, ISLOGICAL.

%   Copyright 2012 The MathWorks, Inc.

tf = isa(t,'categorical');
