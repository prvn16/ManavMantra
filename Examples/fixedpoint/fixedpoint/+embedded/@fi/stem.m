function varargout =stem(varargin)
%STEM   Plot discrete sequence data
%   Refer to the MATLAB STEM reference page for more information.
%
%   See also STEM

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
