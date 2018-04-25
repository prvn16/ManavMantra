function varargout =hist(varargin)
%HIST   Create histogram plot 
%   Refer to the MATLAB HIST reference page for more information.
%
%   See also HIST

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
