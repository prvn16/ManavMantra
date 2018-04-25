function varargout =comet3(varargin)
%COMET3 Create 3-D comet plot
%   Refer to the MATLAB COMET3 reference page for more information.
%
%   See also COMET3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
