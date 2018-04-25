function varargout =ribbon(varargin)
%RIBBON Create 3-D stream ribbon plot
%   Refer to the MATLAB RIBBON reference page for more information.
%
%   See also RIBBON

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
