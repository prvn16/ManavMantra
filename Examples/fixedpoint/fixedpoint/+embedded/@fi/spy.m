function varargout =spy(varargin)
%SPY    Visualize sparsity pattern
%   Refer to the MATLAB SPY reference page for more information.
%
%   See also SPY

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
