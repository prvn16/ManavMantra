function varargout =plotpassthrough(varargin)
%PLOTPASSTHROUGH Draw scatter plots
%   Refer to the MATLAB PLOTPASSTHROUGH reference page for more information.
%
%   See also PLOTPASSTHROUGH

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
