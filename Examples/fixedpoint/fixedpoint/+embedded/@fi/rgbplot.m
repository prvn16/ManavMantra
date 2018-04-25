function varargout =rgbplot(varargin)
%RGBPLOT Plot colormap
%   Refer to the MATLAB RGBPLOT reference page for more information.
%
%   See also RGBPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
