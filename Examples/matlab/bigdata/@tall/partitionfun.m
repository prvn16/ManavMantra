function varargout = partitionfun(opts, fcn, varargin)
%PARTITIONFUN Helper that calls the underlying partitionfun
%
%   PARTITIONFUN(fcn, arg1, ...)
%   PARTITIONFUN(opts, fcn, arg1, ...)

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out opts and fcn
[opts, fcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, fcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@partitionfun, ...
    opts, {fcn}, varargin{:});
end
