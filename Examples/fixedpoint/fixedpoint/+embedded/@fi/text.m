function varargout =text(varargin)
%TEXT   Create text object in current axes
%   Refer to the MATLAB TEXT reference page for more information.
%
%   See also TEXT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
