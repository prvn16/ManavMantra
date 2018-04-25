function varargout = chunkfun(opts, fcn, varargin)
%CHUNKFUN Helper that calls the underlying chunkfun
%
%   CHUNKFUN(fcn, arg1, ...)
%   CHUNKFUN(opts, fcn, arg1, ...)

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out fcn and opts
[opts, fcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, fcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@chunkfun, ...
    opts, {fcn}, varargin{:});
end
