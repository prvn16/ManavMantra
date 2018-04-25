function varargout =plotmatrix(varargin)
%PLOTMATRIX Draw scatter plots
%   Refer to the MATLAB PLOTMATRIX reference page for more information.
%
%   See also PLOTMATRIX

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
