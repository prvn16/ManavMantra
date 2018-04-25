function [varargout] = tsnanmax(varargin)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

% Call [m,ndx] = max(a,b) with as many inputs and outputs as needed
[varargout{1:nargout}] = max(varargin{:});
