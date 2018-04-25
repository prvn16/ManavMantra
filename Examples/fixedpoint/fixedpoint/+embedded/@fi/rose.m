function varargout =rose(varargin)
%ROSE   Create angle histogram
%   Refer to the MATLAB ROSE reference page for more information.
%
%   See also ROSE

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
