function varargout = iptgate(varargin)
%IPTGATE
%   This is an undocumented function and may be removed in a future release.

%IPTGATE Gateway routine to call private functions.
%   IPTGATE is used to access private functions. Private functions 
%   may change in any future release. 
%
%   [OUT1, OUT2,...] = IPTGATE(FCN, VAR1, VAR2,...) calls FCN in
%   MATLABROOT/toolbox/images/images/private with input arguments VAR1,
%   VAR2,... and returns the output, OUT1, OUT2, etc. FCN is a string.
 
%   Copyright 1993-2017 The MathWorks, Inc.

if nargin == 0
    error(message('images:iptgate:invalidNumberOfInputs'))
end

fcnHandle = str2func(varargin{1});
nout = nargout;
if nout == 0
    fcnHandle(varargin{2:end});
else
    [varargout{1:nout}] = fcnHandle(varargin{2:end});
end
