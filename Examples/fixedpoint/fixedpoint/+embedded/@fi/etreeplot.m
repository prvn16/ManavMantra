function varargout =etreeplot(varargin)
%ETREEPLOT Plot elimination tree
%   Refer to the MATLAB ETREEPLOT reference page for more information.
%
%   See also ETREEPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
