function varargout =trimesh(varargin)
%TRIMESH Create triangular mesh plot
%   Refer to the MATLAB TRIMESH reference page for more information.
%
%   See also TRIMESH

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
