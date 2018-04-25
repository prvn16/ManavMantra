function varargout =polar(varargin)
%POLAR  Plot polar coordinates
%   Refer to the MATLAB POLAR reference page for more information.
%
%   See also POLAR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
