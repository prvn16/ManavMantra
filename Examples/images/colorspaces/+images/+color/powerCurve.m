function out = powerCurve(in,gamma)
% powerCurve Power curve
%
%    v = images.color.powerCurve(u,gamma)
%
%    Computes the following function:
%
%        f(u) = u.^gamma        0 <= u
%
%        f(u) = -f(-u)          u < 0
%
%    If u is an array, then the computation is performed elementwise.
%
%    This function does not validate its inputs.

%    Copyright 2014 The MathWorks, Inc.

out = (abs(in).^gamma) .* sign(in);

