function varargout =quiver3(varargin)
%QUIVER3 Create 3-D quiver or velocity plot
%   Refer to the MATLAB QUIVER3 reference page for more information.
%
%   See also QUIVER3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
