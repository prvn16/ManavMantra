function propagateFixed()
%propagateFixed Propagate fixed point.
%
%   propagateFloat Enables a mode that propagates fixed-point outputs of
%   mixed fixedpoint and floating-point operations.
%
%   Examples:
%
%   % Propagate fixed-point.
%   propagateFixed
%   2 * fi(pi)  % returns a fi object
%      
%   % Propagate floating-point.
%   propagateFloat
%   2 * fi(pi)  % returns a floating-point value
%      
%   See also fi, propagateFloat.

%   Copyright 2012-2013 The MathWorks, Inc.
    fixed.internal.setFixedOpFloatingYieldsFixed;
end
