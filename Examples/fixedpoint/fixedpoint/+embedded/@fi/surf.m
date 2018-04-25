function varargout =surf(varargin)
%SURF   Create 3-D shaded surface plot
%   Refer to the MATLAB SURF reference page for more information.
%
%   See also SURF

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
