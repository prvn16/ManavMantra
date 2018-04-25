function varargout =pcolor(varargin)
%PCOLOR Create pseudo-color plot
%   Refer to the MATLAB PCOLOR reference page for more information.
%
%   See also PCOLOR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
