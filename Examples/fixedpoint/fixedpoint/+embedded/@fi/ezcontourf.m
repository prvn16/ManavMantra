function varargout =ezcontourf(varargin)
%EZCONTOURF Easy-to-use filled contour plotter
%   Refer to the MATLAB EZCONTOURF reference page for more information.
%
%   See also EZCONTOURF

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
