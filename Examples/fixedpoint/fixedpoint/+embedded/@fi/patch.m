function varargout =patch(varargin)
%PATCH  Create patch graphics object
%   Refer to the MATLAB PATCH reference page for more information.
%
%   See also PATCH

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
