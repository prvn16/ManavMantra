function varargout = aggregatebykeyfun(opts, perChunkFcn, reduceFcn, varargin)
%AGGREGATEBYKEYFUN Helper that calls the underlying aggregatebykeyfun
%
%   [keys,out1,out2,...] = AGGREGATEBYKEYFUN(perChunkFcn, reduceFcn, key, arg1, arg2, ...)
%   [keys,out1,out2,...] = AGGREGATEBYKEYFUN(opts, perChunkFcn, reduceFcn, key, arg1, arg2, ...)

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out fcn and opts
[opts, perChunkFcn, reduceFcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, perChunkFcn, reduceFcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@aggregatebykeyfun, ...
    opts, {perChunkFcn, reduceFcn}, varargin{:});

% The output keys (varargout{1}) always have the same type and small size as
% the input keys (varargin{1}).
if nargout
    varargout{1}.Adaptor = resetTallSize(varargin{1}.Adaptor);
end

end
