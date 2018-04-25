function varargout =voronoi(varargin)
%VORONOI Create Voronoi diagram
%   Refer to the MATLAB VORONOI reference page for more information.
%
%   See also VORONOI

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

