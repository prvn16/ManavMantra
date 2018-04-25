function varargout =compass(varargin)
%COMPASS Plot arrows emanating from origin
%   Refer to the MATLAB COMPASS reference page for more information.
%
%   See also COMPASS

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
