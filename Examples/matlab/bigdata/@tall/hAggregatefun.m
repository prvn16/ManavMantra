function varargout = hAggregatefun(fcn1,fcn2, varargin)
; %#ok<NOSEM> % Internal only - no help

%HAGGREGATEFUN Helper to call the private slicefun primitive on the input data
%
%  Internal and not supported. Will be removed in a future release.
%
%  Copyright 2016 The MathWorks, Inc.

[varargout{1:nargout}] = aggregatefun(fcn1,fcn2,varargin{:});
end
