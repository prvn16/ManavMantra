function hh = semilogx(varargin)
%SEMILOGX Create semilogarithmic plot with logarithmic x-axis 
%   Refer to the MATLAB SEMILOGX reference page for more information 
%
%   See also SEMILOGX

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

c = todoublecell(varargin{:});
h = semilogx(c{:});
if nargout>0
  hh = h;
end

% LocalWords:  semilogarithmic
