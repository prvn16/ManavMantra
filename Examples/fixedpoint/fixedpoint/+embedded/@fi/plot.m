function hh = plot(varargin)
%PLOT   Create linear 2-D plot
%   Refer to the MATLAB PLOT reference page for more information.
%  
%   See also PLOT 

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

c = todoublecell(varargin{:});
h = plot(c{:});
if nargout>0
  hh = h;
end
