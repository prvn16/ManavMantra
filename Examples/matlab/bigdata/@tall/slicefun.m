function varargout = slicefun(opts, fcn, varargin)
%SLICEFUN Helper that calls the underlying slicefun

%   Copyright 2015-2017 The MathWorks, Inc.

% Strip out fcn and opts
[opts, fcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, fcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@slicefun, opts, {fcn}, varargin{:});

varargout = computeSlicewiseSize(varargout, varargin);
end
