function varargout =ezsurf(varargin)
%EZSURF Easy-to-use 3-D colored surface plotter
%   Refer to the MATLAB EZSURF reference page for more information.
%
%   See also EZSURF

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
