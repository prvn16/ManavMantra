function varargout = datevec(varargin)
%DATEVEC convert tall array to date components.
%   Supported syntaxes for tall DATETIME:
%   DV = DATEVEC(T)
%   [Y,MO,D,H,MI,S] = DATEVEC(T)
%
%   Supported syntaxes for tall array:  
%   V = DATEVEC(N)
%   V = DATEVEC(S,F)
%   V = DATEVEC(S,F,P)
%   V = DATEVEC(S,P,F)
%   [Y,MO,D,H,MI,S] = DATEVEC(...)
%   V = DATEVEC(S)
%   V = DATEVEC(S,P)
%
%   See also DATETIME/DATEVEC, DATEVEC.

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,3);
nargoutchk(0,6);
% We must allow: datetime/calendarDuration/duration/cellstr as the primary data
% arguments, char for flags, and numeric for PivotYear argument.
[varargin{1:nargin}] = tall.validateType(varargin{:}, mfilename, {...
    'datetime', 'calendarDuration', 'duration', ...
    'cellstr', 'char', 'numeric'}, 1:nargin);

% datevec implicitly colonizes its inputs, so we must insist that all input
% arguments are data columns, or character row-vectors.
args = cellfun(@iValidateDatevecArg, varargin, 'UniformOutput', false);

[varargout{1:max(nargout,1)}] = slicefun(@datevec, args{:});
[varargout{:}] = setKnownType(varargout{:}, 'double');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iValidDatevecArg checks whether a given argument is 
function arg = iValidateDatevecArg(arg)

messageId = 'MATLAB:bigdata:array:DatevecInputsColumn';

% Valid arguments are either column vectors (including scalars for PivotYear) or
% character row vectors. The validateType checks above have already eliminated
% completely invalid types. We also allow non-column empties through for no
% really particularly good reason.
predicate = @(x) (ischar(x) && isrow(x)) || iscolumn(x) || isempty(x);

if istall(arg)
    arg = lazyValidate(arg, {predicate, messageId});
elseif ~predicate(arg)
    error(message(messageId));
end
end
