function varargout =zlim(varargin)
%ZLIM   Set or query z-axis limits
%   Refer to the MATLAB ZLIM reference page for more information.
%
%   See also ZLIM

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
