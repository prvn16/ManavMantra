function out = floor(varargin)
%FLOOR  Round towards minus infinity.
%   Supported syntax for tall array:
%   Y = FLOOR(X)
%
%   Supported syntax for tall duration:
%   Y = FLOOR(X)
%   Y = FLOOR(X,UNIT)
%
%   See also FLOOR, DURATION/FLOOR

% Copyright 2017 The MathWorks, Inc.

out = roundFloorCeil(@floor, 1, 2, varargin{:});
end
