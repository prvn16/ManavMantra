function varargout = validateSameTallSize(varargin)
%validateSameTallSize Possibly deferred tall size validation
%   [TX1,TX2,...] = validateSameTallSize(TX1,TX2,...)
%   validates that each of TX1, TX2, ... all have the same size in the tall
%   dimension.
%

% Copyright 2016 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

dataArgs   = varargin;

% It's a mistake not to capture all the outputs since they might be modified.
nData = numel(dataArgs);
nargoutchk(nData, nData);

try
    [varargout{1:nargout}] = iValidateSameTallSize(dataArgs{:});
catch err
    throwAsCaller(err);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = iValidateSameTallSize(varargin)

tallSize = NaN;
for ii = 1:numel(varargin)
    adaptor = matlab.bigdata.internal.adaptors.getAdaptor(varargin{ii});
    if isnan(adaptor.TallSize.Size)
        tallSize = NaN;
        break;
    elseif isnan(tallSize)
        tallSize = adaptor.TallSize.Size;
    elseif tallSize ~= adaptor.TallSize.Size
        error(message('MATLAB:bigdata:array:IncompatibleTallStrictSize'));
    end
end

if isnan(tallSize)
    fh = matlab.bigdata.internal.FunctionHandle(@deal);
    [varargout{1:nargout}] = wrapUnderlyingMethod(@strictslicefun, {fh}, varargin{:});
    for ii = 1:numel(varargout)
        varargout{ii}.Adaptor = matlab.bigdata.internal.adaptors.getAdaptor(varargin{ii});
    end
else
    varargout = varargin;
end
