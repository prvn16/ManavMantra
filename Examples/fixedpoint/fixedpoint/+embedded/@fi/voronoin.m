function varargout =voronoin(varargin)
%VORONOIN Create n-D Voronoi diagram
%   Refer to the MATLAB VORONOIN reference page for more information.
%
%   See also VORONOIN

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
