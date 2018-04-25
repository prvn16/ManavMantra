function varargout = split(tt,varargin)
%SPLIT Extract the time portion of calendar durations or split strings in string array.
%
%   For calendarDuration:
%   [...] = SPLIT(CALDUR,UNITS)
%
%   For string:
%   NEWSTR = SPLIT(STR)
%   NEWSTR = SPLIT(STR,DELIMITER)
%   NEWSTR = SPLIT(STR,DELIMITER,DIM)
%   [NEWSTR,MATCHES] = SPLIT(...)
%
%   See also CALENDARDURATION/SPLIT, STRING/SPLIT.

%   Copyright 2016-2017 The MathWorks, Inc.

tall.checkNotTall(upper(mfilename), 1, varargin{:});
numOut = max(1,nargout);
if strcmp(tt.Adaptor.Class, 'calendarDuration')
    narginchk(2,2);
    [varargout{1:numOut}] = iSplitDuration(tt,varargin{1});
else
    narginchk(1,3);
    nargoutchk(0,2);
    tt = tall.validateType(tt, mfilename, {'string', 'cellstr'}, 1);
    [varargout{1:numOut}] = iSplitString(tt,varargin{:});
end
end

function varargout = iSplitDuration(tt,units)
% Split a calendarDuration into years, months, days
[varargout{1:max(nargout,1)}] = elementfun(@(x)split(x,units), tt);
outTypes = iGetOutputTypes(varargout, units);
for idx = 1:numel(varargout)
    varargout{idx} = setKnownType(varargout{idx}, outTypes{idx});
end
end

function [newstr, matches] = iSplitString(tt,varargin)
% Split each element of a string array, expanding the dimensionality of the
% array. If the dimension is not supplied, the first trailing singleton
% dimension is expanded (i.e. 1x1 -> nx1, 3x1 -> 3xn, 3x2 -> 3x2xn). This
% means we need to know the dimensionality of the input.
if nargin>2
    % If dimension is supplied it must not be the first.
    dim = varargin{2};
    if isequal(dim,1)
        error(message('MATLAB:bigdata:array:SplitCannotExpandTall'));
    end
    % Check it's a valid dimension
    if ~isnumeric(dim) || ~isscalar(dim) || ~isreal(dim) ...
            || ~isfinite(dim) || dim<1 || dim~=round(dim)
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    % We now know that the tall size is unaffected, so use slicefun
    [newstr, matches] = iSplitStringSlicewise(tt, varargin{:});
    return
end

% For the remainder we need a delimiter even if the user didn't provide one
% (so that we can specify the dimension).
if nargin<2
    % See MATLAB doc for ISSPACE for an explanation of this:
    whitespaceIdx = find(isspace(char(1):char(intmax('uint16'))));
    % Convert unicode indices into cellstr, as required by string/split
    delimiter = arrayfun(@char, whitespaceIdx, 'UniformOutput', false);
else
    delimiter = varargin{1};
end

% Must deduce dim. All we really care about is whether it could be 1, but
% since we must pass it to the workers we have to calculate it. If the
% sizes aren't known we do this lazily using clientfun.
if tt.Adaptor.isSizeKnown() || iCanDetermineNonUnitySizes(tt.Adaptor)
    dim = iFirstTrailingDim(tt.Adaptor.Size);
    % If definitely >1, use slicefun
    if dim>1
        [newstr, matches] = iSplitStringSlicewise(tt, delimiter, dim);
        return
    end
else
    dim = clientfun(@iFirstTrailingDim, size(tt));
    dim.Adaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();
end
[newstr, matches] = chunkfun(@iDoSplit, tt, delimiter, dim);
% Output is same type as input with size as set by chunkfun.
newstr.Adaptor = copySizeInformation(tt.Adaptor, newstr.Adaptor);
matches.Adaptor = copySizeInformation(tt.Adaptor, matches.Adaptor);
end

function dim = iFirstTrailingDim(sz)
% Find the first unity dimension after the last non-unity dimension. Note
% that NaN is treated as non-unity, so don't call this if a NaN dimension
% could be 1.
idx = find(sz~=1,1,'last'); % This will treat NaN as non-unity
if isempty(idx)
    dim = 1;
else
    dim = idx+1;
end
end

function tf = iCanDetermineNonUnitySizes(ad)
% Can we guarantee at least one non-unity size and that we can determine
% where it is.
tf = (ad.isSmallSizeKnown() ...
    && (prod(ad.SmallSizes)~=1 || ad.isTallSizeGuaranteedNonUnity()));
end

function [newstr, matches] = iSplitStringSlicewise(tt, varargin)
% Helper to split a string slice-wise and set the output adaptor correctly
[newstr, matches] = slicefun(@(x) iDoSplit(x,varargin{:}), tt ); % Bind in args since delimiter might not be scalar
% Output is same type as input with size as set by slicefun.
newstr.Adaptor = copySizeInformation(tt.Adaptor, newstr.Adaptor);
matches.Adaptor = copySizeInformation(tt.Adaptor, matches.Adaptor);
end

function [a,b] = iDoSplit(t, delimiter, dim)
% Call SPLIT with handling of empty partitions.

% We need to be careful for empty partitions since SPLIT will return
% something that can't be combined with other partitions. Instead return
% 0x0 since that can be concatenated with anything.
if size(t,1)==0
    if isstring(t)
        a = string.empty(0,0);
        b = string.empty(0,0);
    else
        a = cell.empty(0,0);
        b = cell.empty(0,0);
    end
else
    [a,b] = split(t, delimiter, dim);
end
end

function types = iGetOutputTypes(cellY, units)
% compute the appropriate Adaptor for output.
dummyCell = cell(size(cellY));
[dummyCell{:}] = split(calendarDuration(1,1,1),units);
types = cellfun(@class, dummyCell, 'UniformOutput', false);
end
