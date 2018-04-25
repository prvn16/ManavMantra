function varargout =treeplot(varargin)
%TREEPLOT Plot picture of tree
%   Refer to the MATLAB TREEPLOT reference page for more information.
%
%   See also TREEPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2012 The MathWorks, Inc.

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
