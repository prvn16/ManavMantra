function varargout = clientfun(opts, fcn, varargin)
%CLIENTFUN Helper that calls the underlying clientfun
%
%   CLIENTFUN(fcn, arg1, ...)
%   CLIENTFUN(opts, fcn, arg1, ...)

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out opts and fcn
[opts, fcn, varargin] = matlab.bigdata.internal.util.stripOptions(opts, fcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@clientfun, opts, {fcn}, varargin{:});
end
