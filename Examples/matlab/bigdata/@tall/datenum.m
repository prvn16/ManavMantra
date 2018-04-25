function tn = datenum(varargin)
%DATENUM convert tall array to serial date number.
%   Supported syntaxes for tall DATETIME:
%   DN = DATENUM(T)
%
%   Supported syntaxes for tall array:
%   N = DATENUM(V)
%   N = DATENUM(S,F)
%   N = DATENUM(S,F,P)
%   N = DATENUM(S,P,F)
%   N = DATENUM(Y,MO,D)
%   N = DATENUM([Y,MO,D])
%   N = DATENUM(Y,MO,D,H,MI,S)
%   N = DATENUM([Y,MO,D,H,MI,S])
%   N = DATENUM(S)
%   N = DATENUM(S,P)
%
%   See also DATETIME/DATENUM, DATENUM.

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(1,6);
[varargin{1:nargin}] = tall.validateType(varargin{:}, mfilename, ...
    {'cellstr', 'char', 'numeric', 'datetime', 'duration'}, ...
    1:nargin);

% Handle DATEVEC input as a special case. This requires an extra pass, so
% we want to avoid this where possible.
if nargin == 1 ...
        && ~any(tall.getClass(varargin{1}) == ["cell", "datetime", "duration"])
    sz = varargin{1}.Adaptor.getSizeInDim(2);
    if isnan(sz) || any(sz == [3, 6])
        requiresDatevec = aggregatefun(@iCheckForDatevec, @any, varargin{:});
        tn = slicefun(@iDatenumSingleArg, requiresDatevec, varargin{:});
        return;
    end
end

tn = slicefun(@iDatenum, varargin{:});

end

function tf = iCheckForDatevec(arg1)
% Check if the current chunk requires special handling of datenum to convert
% all inputs from DATEVEC.
sz = size(arg1);
tf = isnumeric(arg1) ...
    && any(sz(2) == [3, 6]) ...
    && any(prod(sz(2 : end)) == [3, 6]) ...
    && any(abs(arg1(:,1) - 2000) < 10000);
end

function x = iDatenumSingleArg(requiresDatevec, varargin)
% If any chunk requires special handling, do special handling for all
% chunks.
if requiresDatevec
    varargin = num2cell(varargin{1}(:, :, 1), 1);
end
x = iDatenum(varargin{:});
end

function n = iDatenum(varargin)
% Invoke datenum, disallowing string input when not a column vector. We do
% this because string datenum does not have consistent behavior when
% applied to a non-vector string array.
if ~iscolumn(varargin{1}) && (isstring(varargin{1}) || iscellstr(varargin{1}))
    error(message('MATLAB:bigdata:array:DatenumNonColumnString'));
end
% This warning is issued on empty chunks. This is disabled as it might
% generate many warnings during a single gather.
warnState = warning('off', 'MATLAB:datenum:EmptyDate');
warnCleanup = onCleanup(@() warning(warnState));
n = datenum(varargin{:});
end
