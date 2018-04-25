function out = str2double(in)
%STR2DOUBLE Convert tall string array to double precision value.
%   X = STR2DOUBLE(S)
%
%   See also: tall/strrep.

%   Copyright 2015-2016 The MathWorks, Inc.

% STR2DOUBLE returns nan for char arrays with more than one row, so only
% allow arrays of strings, cell arrays of char vectors.
in = tall.validateType(in, mfilename, {'string', 'cellstr'}, 1);

% We only support cellstr or string arrays, so are element-wise
out = elementfun(@str2double, in);
out = setKnownType(out, 'double');
end
