function varargout =ezplot(varargin)
%EZPLOT Easy-to-use function plotter
%   Refer to the MATLAB EZPLOT reference page for more information.
%
%   See also EZPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
