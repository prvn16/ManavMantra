function varargout = avgate(varargin)
%AVGATE Gateway routine to call MATLAB audio/video private functions.
%
%    [OUT1, OUT2,...] = AVGATE(FCN, VAR1, VAR2,...) calls FCN in 
%    the MATLAB audio/video private directory with input arguments
%    VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%

%    Copyright 2007-2013 The MathWorks, Inc.

if nargin == 0
    error(message('MATLAB:audiovideo:avgate:invalidSyntax'));
end

nout = nargout;
if nout==0,
   feval(varargin{:});
else
   [varargout{1:nout}] = feval(varargin{:});
end
