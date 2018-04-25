function varargout =streamtube(varargin)
%STREAMTUBE Create 3-D stream tube plot
%   Refer to the MATLAB STREAMTUBE reference page for more information.
%
%   See also STREAMTUBE

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
