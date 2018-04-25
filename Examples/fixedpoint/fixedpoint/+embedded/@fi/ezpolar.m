function varargout =ezpolar(varargin)
%EZPOLAR Easy-to-use polar coordinate plotter
%   Refer to the MATLAB EZPOLAR reference page for more information.
%
%   See also EZPOLAR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
