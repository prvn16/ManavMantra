function hh = semilogy(varargin)
%SEMILOGY Create semilogarithmic plot with logarithmic y-axis 
%   Refer to the MATLAB SEMILOGY reference page for more information. 
%
%   See also SEMILOGY

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

c = todoublecell(varargin{:});
h = semilogy(c{:});
if nargout>0
  hh = h;
end
