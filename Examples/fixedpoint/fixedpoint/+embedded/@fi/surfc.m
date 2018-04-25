function varargout =surfc(varargin)
%SURFC  Create 3-D shaded surface plot with contour plot
%   Refer to the MATLAB SURFC reference page for more information.
%
%   See also SURFC

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
