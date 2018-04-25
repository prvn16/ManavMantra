function varargout =ezcontour(varargin)
%EZCONTOUR Easy-to-use contour plotter
%   Refer to the MATLAB EZCONTOUR reference page for more information.
%
%   See also EZCONTOUR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
