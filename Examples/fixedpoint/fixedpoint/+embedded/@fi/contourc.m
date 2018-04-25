function varargout =contourc(varargin)
%CONTOURC Create two-level contour plot computation
%   Refer to the MATLAB CONTOURC reference page for more information.
%
%   See also CONTOURC

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
