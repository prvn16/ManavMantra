function varargout =histc(varargin)
%HISTC  Histogram count
%   Refer to the MATLAB HISTC reference page for more information.
%
%   See also HISTC

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

