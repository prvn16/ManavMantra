function varargout =clabel(varargin)
%CLABEL Create contour plot elevation labels
%   Refer to the MATLAB CLABEL reference page for more information.
%
%   See also CLABEL

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
