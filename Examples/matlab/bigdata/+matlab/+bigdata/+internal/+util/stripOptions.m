function varargout = stripOptions(varargin)
% Helper to strip an optional PartitionedArrayOptions argument from an
% input list. If the options are not present they are default constructed.
%
% Example:
% [opts, varargin] = matlab.bigdata.internal.util.stripOptions(varargin{:})
% [opts, fun, varargin] = matlab.bigdata.internal.util.stripOptions(opts, fun, varargin{:})
%
% See also: matlab.bigdata.internal.PartitionedArrayOptions

% Copyright 2017 The MathWorks, Inc.

if isa(varargin{1}, 'matlab.bigdata.internal.PartitionedArrayOptions')
    opts = varargin{1};
    varargin(1) = [];
else
    opts = matlab.bigdata.internal.PartitionedArrayOptions;
end

% If caller requested more than two outputs, also strip more out, e.g.
%  [opts, fun, varargin] = stripOptions(varargin{:})
if nargout>2
    varargout = cell(1,nargout);
    numToSplit = nargout-2;
    varargout{1} = opts;
    for idx=1:numToSplit
        varargout{idx+1} = varargin{idx};
    end
    varargout{end} = varargin(numToSplit+1:end);
else
    % Two outputs
    varargout = {opts, varargin};
end