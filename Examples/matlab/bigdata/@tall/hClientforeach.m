function varargout = hClientforeach(fcn1, fcn2, varargin)
; %#ok<NOSEM> % Internal only - no help

%HCLIENTFOREACH Helper to call the private clientforeach primitive on the input data
%
%  Copyright 2017 The MathWorks, Inc.

[varargout{1:nargout}] = clientforeach(fcn1, fcn2, varargin{:});
end
