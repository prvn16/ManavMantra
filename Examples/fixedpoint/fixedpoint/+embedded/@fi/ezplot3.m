function varargout =ezplot3(varargin)
%EZPLOT3 Easy-to-use 3-D parametric curve plotter
%   Refer to the MATLAB EZPLOT3 reference page for more information.
%
%   See also EZPLOT3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
