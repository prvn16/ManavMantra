function ts = datestr(tx, varargin)
%DATESTR convert tall array to character representation of date.
%   Supported syntaxes for tall DATETIME:
%   C = DATESTR(T)
%   S = DATESTR(T,F)
%
%   Supported syntaxes for tall array:  
%   S = DATESTR(V)
%   S = DATESTR(N)
%   S = DATESTR(D,F)
%   S = DATESTR(S1,F,P)
%   S = DATESTR(...,'local')
%
%   Limitations:
%   1) First argument must be a column vector or an array returned by DATEVEC.
%   2) If the first argument is a DATEVEC array, then the rows must be within
%   the year range 1500:2499.
%
%   See also DATETIME/DATESTR, DATESTR.

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(1,4);
tall.checkIsTall(upper(mfilename), 1, tx);
tall.checkNotTall(upper(mfilename), 1, varargin{:});
tall.validateSyntax(@datestr, [{tx}, varargin], ...
    'DefaultType', 'double');

if nargin < 2 || (nargin == 2 && (isequal(varargin{1}, 'local') || isequal(varargin{1}, 'en-us')))
    format = iDetermineFormat(tx);
    varargin = [{format}, varargin(2 : end)];
end

ts = slicefun(@iDatestr, tx, varargin{:});
ts = setKnownType(ts, 'char');
end

function str = iDatestr(varargin)
% Invoke datestr and issue a specific error if the inputs do not meet the
% supported constraints.
str = datestr(varargin{:});
if size(str, 1) ~= size(varargin{1}, 1)
    % The output size is unexpected. This can happen for two reasons:
    %  1. The input was an array of datenum/datetime. Datestr colonizes the
    %  input.
    %  2. The input was a bad DATEVEC array.
    error(message('MATLAB:bigdata:array:DatestrUnsupportedInput'));
end
end

function format = iDetermineFormat(tx)
% Determine the default format ID of the given data.
format = aggregatefun(@iGetFormatOfChunk, @iReduceFormat, tx);
format = clientfun(@iCheckForNoFormat, format);
end

function format = iGetFormatOfChunk(x)
% Get the default format ID of the given chunk of data.
dtnumber = datenum(x);
if isempty(dtnumber)
    % No concrete format as chunk is empty.
    format = NaN;
elseif all(floor(dtnumber)==dtnumber)
    % All values have only a date component.
    format = 1;
elseif all(floor(dtnumber)==0)
    % All values have only a time component.
    format = 16;
else
    % Values consist of both dates and times (or both together).
    format = 0;
end
end

function format = iReduceFormat(format)
% Reduce a collection of default format IDs into one that represents all of
% the data.
format = unique(format(~isnan(format)));
if isempty(format)
    format = NaN;
elseif numel(format) > 1
    format = 0;
end
end

function format = iCheckForNoFormat(format)
% Check for the case that all partitions was empty and treat that as
% special.
if isnan(format)
    format = 1;
end
end
