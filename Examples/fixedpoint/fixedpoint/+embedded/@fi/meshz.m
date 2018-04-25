function varargout =meshz(varargin)
%MESHZ  Create mesh plot with curtain plot
%   Refer to the MATLAB MESHZ reference page for more information.
%
%   See also MESHZ

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
