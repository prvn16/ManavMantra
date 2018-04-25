function varargout =gplot(varargin)
%GPLOT  Plot set of nodes using adjacency matrix
%   Refer to the MATLAB GPLOT reference page for more information.
%
%   See also GPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
