function varargout =comet(varargin)
%COMET  Create 2-D comet plot
%   Refer to the MATLAB COMET reference page for more information.
%
%   See also COMET

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
