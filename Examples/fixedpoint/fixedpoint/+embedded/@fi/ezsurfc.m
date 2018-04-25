function varargout =ezsurfc(varargin)
%EZSURFC Easy-to-use combination surface/contour plotter
%   Refer to the MATLAB EZSURFC reference page for more information.
%
%   See also EZSURFC

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
