function varargout =scatter(varargin)
%SCATTER Create scatter or bubble plot
%   Refer to the MATLAB SCATTER reference page for more information.
%
%   See also SCATTER

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
