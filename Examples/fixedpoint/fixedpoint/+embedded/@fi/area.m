function varargout =area(varargin)
%AREA   Create filled area 2-D plot
%   Refer to the MATLAB AREA reference page for more information.
%
%   See also AREA

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
