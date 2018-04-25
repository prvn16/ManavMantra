function out = strrep(in, oldSubstr, newSubstr)
%STRREP Replace string with another.
%   MODIFIEDSTR = STRREP(ORIGSTR,OLDSUBSTR,NEWSUBSTR)
%
%   Limitations:
%   ORIGSTR must be a tall array of strings or a cell array of strings,
%   OLDSUBSTR and NEWSUBSTR must be a single string or a similarly sized
%   tall array of strings.

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(3,3);
nargoutchk(0,1);

% We require that the first input is the tall array and the others are
% plain strings or similarly sized tall arrays of strings
if ~istall(in)
    error(message('MATLAB:bigdata:array:StrrepNotTall'))
end
in = validateAndMaybeWrap(in, mfilename, 1);
oldSubstr = validateAndMaybeWrap(oldSubstr, mfilename, 2);
newSubstr = validateAndMaybeWrap(newSubstr, mfilename, 3);

% All inputs are cellstr or strings so we can use element-wise rules
out = elementfun(@strrep, in, oldSubstr, newSubstr);

% We do not allow char first input, so the output type is:
% * string if any input is string
% * otherwise, unknown if any input is unknown (we can't rule out string)
% * otherwise, cell
classes = {tall.getClass(in), tall.getClass(oldSubstr), tall.getClass(newSubstr)};
if any(classes == "string")
    out = setKnownType(out, 'string');
elseif any(cellfun(@isempty, classes))
    % At least one is unknown, so can't tell the type
else
    assert(any(classes == "cell"), 'Expected at least one input to be a cellstr');
    out = setKnownType(out, 'cell');
end


end % strrep

function arg = validateAndMaybeWrap(arg, fcnName, argIdx)
% Check a substring input to make sure it is valid. Allowed types are:
% * a char row vector
% * a scalar string
% * a scalar cell containing a char array
% * a tall string array or cellstr the same length as the first input
%
% Tall arguments are validated lazily and must be arrays. Non-tall
% arguments are validated immediately and then broadcast so that they can
% be passed directly to STRREP.

if istall(arg)
    arg = tall.validateType(arg, fcnName, {'string', 'cellstr'}, argIdx);
else
    if ~isValidString(arg)
        error(message('MATLAB:strrep:InvalidInputType'));
    end
    % If the argument is char-array, wrap in a cell so that we don't try and
    % expand dimensions
    if ischar(arg)
        arg = {arg};
    end
end
end % validateAndMaybeWrap

