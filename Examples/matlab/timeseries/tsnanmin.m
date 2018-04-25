function [varargout] = tsnanmin(varargin)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

% Call [m,ndx] = min(a,b) with as many inputs and outputs as needed
[varargout{1:nargout}] = min(varargin{:});
