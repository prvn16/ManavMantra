function out = round(varargin)
%ROUND  rounds towards nearest decimal or integer
%   Support syntax for tall array:
%   Y = ROUND(X)
%   Y = ROUND(X, N)
%   Y = ROUND(X, N, 'significant')
%   Y = ROUND(X, N, 'decimals')
%
%   Support syntax for tall duration:
%   B = ROUND(A)
%   B = ROUND(A,UNIT)
%
%   See also ROUND, DURATION/ROUND.

%   Copyright 2016-2017 The MathWorks, Inc.

out = roundFloorCeil(@round, 3, 2, varargin{:});
end
