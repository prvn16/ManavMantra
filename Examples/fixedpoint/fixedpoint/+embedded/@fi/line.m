function varargout =line(varargin)
%LINE   Create line object
%   Refer to the MATLAB LINE reference page for more information.
%
%   See also LINE

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
