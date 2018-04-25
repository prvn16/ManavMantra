function [narg, method, ExtrapVal] = methodandextrapval(varargin)
%METHODANDEXTRAPVAL parses the method and ExtrapVal from the arguments
%   [NARG, METHOD, EXTRAPVAL] = METHODANDEXTRAPVAL(VARARGIN)
%   Parses VARARGIN to extract METHOD, and EXTRAPVAL and returns the number
%   of remaining arguments in NARG. This is a common utility function used
%   by INTERP2, INTERP3, INTERPN
%

%   Copyright 2012-2017 The MathWorks, Inc.

narg = nargin;
ExtrapVal = [];
if isnumeric(varargin{end}) && isscalar(varargin{end}) && ...
        (ischar(varargin{end-1}) || (isstring(varargin{end-1}) && isscalar(varargin{end-1})))
    % User supplied an extrap val
    ExtrapVal = varargin{end};
    method_arg = varargin{end-1};
    narg = narg-2;
elseif ischar(varargin{end}) || (isstring(varargin{end}) && isscalar(varargin{end}))
    method_arg = varargin{end};
    narg = narg-1;
else
    method_arg = 'linear';
end

% Parse the method_arg

if strncmp(method_arg,'*',1)
    method_arg = method_arg(2:end);
    % TODO issue a deprecation WARNING
end
if strncmpi(method_arg,'n',1)
    method = 'nearest';
elseif strncmpi(method_arg,'l',1) ||  (numel(method_arg) >=3 && strcmpi(method_arg(1:3),'bil'))
    method = 'linear';
elseif strncmpi(method_arg,'s',1)
    method = 'spline';
elseif strncmpi(method_arg,'c',1)  ||  (numel(method_arg) >=3 && strcmpi(method_arg(1:3),'bic') )
    method = 'cubic';
elseif strncmpi(method_arg,'m',1)
    method = 'makima';
else
    method = method_arg;
end

end
