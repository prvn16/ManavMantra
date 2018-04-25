function varargout =contourf(varargin)
%CONTOURF Create filled 2-D contour plot
%   Refer to the MATLAB CONTOURF reference page for more information.
%
%   See also CONTOURF

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
