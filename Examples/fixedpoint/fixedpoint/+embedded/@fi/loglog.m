function hh = loglog(varargin)
%LOGLOG Create log-log scale plot
%   Refer to the MATLAB LOGLOG reference page for more details.
%
%   See also PLOT

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

c = todoublecell(varargin{:});
h = loglog(c{:});
if nargout>0
  hh = h;
end
