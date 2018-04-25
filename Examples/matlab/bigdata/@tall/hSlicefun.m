function varargout = hSlicefun(fcn, varargin)
; %#ok<NOSEM> % Internal only - no help

%HSLICEFUN Helper to call the private slicefun primitive on the input data
%
%  Internal and not supported. Will be removed in a future release.
%
%  Copyright 2016 The MathWorks, Inc.

[varargout{1:nargout}] = slicefun(fcn,varargin{:});
end
