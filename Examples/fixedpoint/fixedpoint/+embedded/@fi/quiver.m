function varargout =quiver(varargin)
%QUIVER Create quiver or velocity plot
%   Refer to the MATLAB QUIVER reference page for more information.
%
%   See also QUIVER

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
