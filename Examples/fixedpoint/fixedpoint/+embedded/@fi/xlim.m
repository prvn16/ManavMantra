function varargout =xlim(varargin)
%XLIM   Set or query x-axis limits
%   Refer to the MATLAB XLIM reference page for more information.
%
%   See also XLIM

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
