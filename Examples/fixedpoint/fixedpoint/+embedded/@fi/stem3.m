function varargout =stem3(varargin)
%STEM3  Plot 3-D discrete sequence data
%   Refer to the MATLAB STEM3 reference page for more information.
%
%   See also STEM3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
