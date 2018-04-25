function varargout =contour3(varargin)
%CONTOUR3 Create 3-D contour plot
%   Refer to the MATLAB CONTOUR3 reference page for more information.
%
%   See also CONTOUR3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
