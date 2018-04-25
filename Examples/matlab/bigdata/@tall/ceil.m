function out = ceil(varargin)
%CEIL  Round towards plus infinity.
%   Supported syntax for tall array:
%   Y = CEIL(X)
%
%   Supported syntax for tall duration:
%   Y = CEIL(X)
%   Y = CEIL(X,UNIT)
%
%   See also CEIL, DURATION/CEIL

% Copyright 2017 The MathWorks, Inc.
out = roundFloorCeil(@ceil, 1, 2, varargin{:});
end
