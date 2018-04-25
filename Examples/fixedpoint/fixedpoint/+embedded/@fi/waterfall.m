function varargout =waterfall(varargin)
%WATERFALL Create waterfall plot
%   Refer to the MATLAB WATERFALL reference page for more information.
%
%   See also WATERFALL

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
