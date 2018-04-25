function out = replace(in, oldSubstr, newSubstr)
%REPLACE Replace string with another.
%   MODIFIEDSTR = REPLACE(ORIGSTR,OLDSUBSTR,NEWSUBSTR)
%
%   See also TALL/STRING.

%   Copyright 2016 The MathWorks, Inc.

narginchk(3,3);

% First input must be a tall string.
if ~istall(in)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
in = tall.validateType(in, mfilename, {'string'}, 1);
oldSubstr = wrapCharInput(oldSubstr);
newSubstr = wrapCharInput(newSubstr);

% Rest just duplicates STRREP, but because STRREP doesn't yet support the
% new string class, we need to convert to CELLSTR and back.
out = elementfun(@replace, in, oldSubstr, newSubstr);
out = setKnownType(out, 'string');
end
