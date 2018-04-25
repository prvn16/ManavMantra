function tf = isNumLogical(x)
%ISNUMLOGICAL Validate a scalar logical input.
%   This function returns true if x is a scalar logical or a scalar numeric
%   and false otherwise.

%   Copyright 2015 The MathWorks, Inc.

tf = isscalar(x) && ( islogical(x) || isnumeric(x) );
end