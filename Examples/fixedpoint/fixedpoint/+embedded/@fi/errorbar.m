function varargout =errorbar(varargin)
%ERRORBAR Plot error bars along curve
%   Refer to the MATLAB ERRORBAR reference page for more information.
%
%   See also ERRORBAR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
