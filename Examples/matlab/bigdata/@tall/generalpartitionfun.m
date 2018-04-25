function varargout = generalpartitionfun(opts, fcn, varargin)
%GENERALPARTITIONFUN Helper that calls the underlying generalpartitionfun
%
%   GENERALPARTITIONFUN(fcn, arg1, ...)
%   GENERALPARTITIONFUN(opts, fcn, arg1, ...)

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out opts and fcn
[opts, fcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, fcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@generalpartitionfun, ...
    opts, {fcn}, varargin{:});
end
