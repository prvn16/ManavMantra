function varargout =mesh(varargin)
%MESH   Create mesh plot
%   Refer to the MATLAB MESH reference page for more information.
%
%   See also MESH

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

