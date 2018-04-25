function varargout =contour(varargin)
%CONTOUR Create contour graph of matrix
%   Refer to the MATLAB CONTOUR reference page for more information.
%
%   See also CONTOUR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
