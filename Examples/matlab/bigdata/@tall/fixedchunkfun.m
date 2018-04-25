function varargout = fixedchunkfun(opts, numSlicesPerChunk, fcn, varargin)
%FIXEDCHUNKFUN Helper that calls the underlying chunkfun
%
%   FIXEDCHUNKFUN(numSlicesPerChunk, fcn, varargin)
%   FIXEDCHUNKFUN(opts, numSlicesPerChunk, fcn, varargin)

%   Copyright 2016-2017 The MathWorks, Inc.

% Strip out opts and fcn
[opts, numSlicesPerChunk, fcn, varargin] = ...
    matlab.bigdata.internal.util.stripOptions(opts, numSlicesPerChunk, fcn, varargin{:});

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

[varargout{1:nargout}] = wrapUnderlyingMethod(@fixedchunkfun, ...
    opts, {numSlicesPerChunk, fcn}, varargin{:});
end
