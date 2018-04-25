function varargout =plot3(varargin)
%PLOT3  Create 3-D line plot
%   Refer to the MATLAB PLOT3 reference page for more information.
%
%   See also PLOT3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
