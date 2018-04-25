function varargout = size(A,varargin)
%SIZE   Matrix dimensions
%   Refer to the MATLAB SIZE reference page for more information.
%
%   See also SIZE

%   Copyright 1999-2014 The MathWorks, Inc.
narginchk(1,2);
if isfi(A)
    % size(A,...) where A is a fi object
    [varargout{1:nargout}] = fi_size(A,varargin{:});
else
    % size(A,dim) where A is not a fi object and dim is a fi object
    c = todoublecell(varargin{:});
    [varargout{1:nargout}] = size(A,c{:});
end
