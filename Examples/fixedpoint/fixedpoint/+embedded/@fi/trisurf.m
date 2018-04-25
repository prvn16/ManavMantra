function varargout =trisurf(varargin)
%TRISURF Create triangular surface plot
%   Refer to the MATLAB TRISURF reference page for more information.
%
%   See also TRISURF

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
