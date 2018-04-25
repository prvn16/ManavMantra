function varargout =slice(varargin)
%SLICE  Draw streamlines in slice planes
%   Refer to the MATLAB SLICE reference page for more information.
%
%   See also SLICE

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
