function varargout =ezmesh(varargin)
%EZMESH Easy-to-use 3-D mesh plotter
%   Refer to the MATLAB EZMESH reference page for more information.
%
%   See also EZMESH

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
