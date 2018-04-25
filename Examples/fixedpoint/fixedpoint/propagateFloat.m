function propagateFloat()
%propagateFloat Propagate floating point.
%
%   propagateFloat Enables a mode that propagates floating-point outputs of
%   mixed fixedpoint and floating-point operations.
%
%   Examples:
%
%   % Propagate floating-point.
%   propagateFloat
%   2 * fi(pi)  % returns a floating-point value
%      
%   % Propagate fixed-point.
%   propagateFixed
%   2 * fi(pi)  % returns a fi object
%
%   See also fi, propagateFixed.

%   Copyright 2012-2013 The MathWorks, Inc.

    fixed.internal.setFixedOpFloatingYieldsFloating;
end
