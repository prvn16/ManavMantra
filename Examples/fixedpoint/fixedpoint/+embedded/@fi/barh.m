function varargout =barh(varargin)
%BARH   Create horizontal bar graph
%   Refer to the MATLAB BARH reference page for more information.
%
%   See also BARH

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
