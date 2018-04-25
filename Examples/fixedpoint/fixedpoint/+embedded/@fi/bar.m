function varargout =bar(varargin)
%BAR    Create vertical bar graph
%   Refer to the MATLAB BAR reference page for more information.
%
%   See also BAR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
