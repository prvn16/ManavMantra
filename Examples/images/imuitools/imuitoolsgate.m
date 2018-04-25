function varargout = imuitoolsgate(varargin)
%IMUITOOLSGATE
%   This is an undocumented function and may be removed in a future release.

%IMUITOOLSGATE Gateway routine to call private functions.
%   IMUITOOLSGATE is used to access private functions. Private functions
%   may change in any future release.
%
%   [OUT1, OUT2,...] = IMUITOOLSGATE(FCN, VAR1, VAR2,...) calls FCN in
%   MATLABROOT/toolbox/images/imuitools/private with input arguments
%   VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%
%   FUNCTION_HANDLE = IMUITOOLSGATE('FunctionHandle', FCN) returns a handle
%   FUNCTION_HANDLE to the function FCN in
%   MATLABROOT/toolbox/images/imuitools/private. FCN is a string.
 
%   Copyright 2003-2017 The MathWorks, Inc.

warning(message('images:imuitoolsgate:undocumentedFunction'))

if nargin == 0
    error(message('images:imuitoolsgate:invalidNumberOfInputs'))
end

varargin = matlab.images.internal.stringToChar(varargin);

match = strncmp(varargin{1}, 'FunctionHandle', length(varargin{1}));
if match
    fcnHandle = str2func(varargin{2});
    varargout{1} = fcnHandle;

else
    fcnHandle = str2func(varargin{1});

    nout = nargout;
    if nout == 0
        fcnHandle(varargin{2:end});
    else
        [varargout{1:nout}] = fcnHandle(varargin{2:end});
    end
end
