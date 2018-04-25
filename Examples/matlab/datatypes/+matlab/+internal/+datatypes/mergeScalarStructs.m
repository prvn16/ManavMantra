function s = mergeScalarStructs(varargin)
%MERGESCALARSTRUCTS Combine two or more scalar structs into one with the combined set of fields
%   S = MERGESCALARSTRUCTS(S1,S2,...) returns a scalar struct S that contains all of the
%   fields of the scalar structs S1, S2, ... . If any of the input structs contain the
%   same field, the result contains the value from the last input field.
%
%   This function has no error checking. The inputs must be scalar structs.

%   Copyright 2016 The MathWorks, Inc.

s = varargin{1};
assert(isscalar(s));
for i = 2:nargin
    si = varargin{i};
    assert(isscalar(si));
    fi = fieldnames(si);
    for j = 1:length(fi)
        fn = fi{j};
        s.(fn) = si.(fn);
    end
end