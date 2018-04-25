function out = strfind(txt, pattern, varargin)
%STRFIND  Find one string within another.
%   K = STRFIND(TEXT,PATTERN)
%   K = STRFIND(TEXT,PATTERN,'ForceCellOutput',CELLOUTPUT)
%
%   Limitations:
%   TEXT must be a tall array of strings or a tall cell array of strings.
%   PATTERN must be a single string, and must not be a tall array.
%   The output is always a tall cell array of index vectors.
%   K is always a cell vector with one element per input string
%
%   Example:
%     s = {'How much wood'; 'would a woodchuck chuck?'};
%     S = tall(s);
%     strfind(S,'wo')
%
%   See also: STRFIND, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,4);

% First input must be a tall array of strings. Subsequent inputs are
% parameters and will be bound into the call.

% We require that the first input is the tall array and the second is
% a single string
if ~istall(txt)
    error(message('MATLAB:bigdata:array:InvalidStringInput', 'STRFIND'));
end
txt = tall.validateType(txt, mfilename, {'string', 'cellstr'}, 1);
if ~isSingleString(pattern)
    error(message('MATLAB:string:MustBeSingleString', 'PATTERN'));
end

% Wrap char input in a string so that it is treated as a single element
if ischar(pattern)
    pattern = string(pattern);
end
% May get more than one result per row, so use slice-wise rules
out = slicefun(@(t,p) iWrapStrfind(t, p, varargin{:}), txt, pattern);

end % strfind


function tf = isSingleString(in)
% check if the input is a single string (char vector, scalar string or
% scalar cellstr)
tf = isNonTallScalarString(in) ...
    || (iscellstr(in) && isscalar(in));
end % isSingleString

function out = iWrapStrfind(varargin)
% Wrap STRFIND so that it reliably returns cell outputs (otherwise we can
% hit concatenation problems)
out = strfind(varargin{:});
if ~iscell(out)
    out = {out};
end
end
