function varargout =feather(varargin)
%FEATHER Plot velocity vectors
%   Refer to the MATLAB FEATHER reference page for more information.
%
%   See also FEATHER

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
