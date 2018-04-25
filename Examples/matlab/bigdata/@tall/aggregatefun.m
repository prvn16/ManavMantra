function varargout = aggregatefun(opts, perChunkFcn, reduceFcn, varargin)
%AGGREGATEFUN Helper that calls the underlying aggregatefun
%
%   AGGREGATEFUN(perChunkFcn, reduceFcn, arg1, arg2, ...)
%   AGGREGATEFUN(opts, perChunkFcn, reduceFcn, arg1, arg2, ...)

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out fcn and opts
[opts, perChunkFcn, reduceFcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, perChunkFcn, reduceFcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@aggregatefun, ...
    opts, {perChunkFcn, reduceFcn}, varargin{:});
end
