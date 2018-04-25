function t = isfinite(this)
%ISFINITE True for finite elements
%   Refer to the MATLAB ISFINITE reference page for more information.
%
%   See also ISFINITE

%   Copyright 2003-2012 The MathWorks, Inc.

if isfixed(this) || isboolean(this)
    % fixed-point values and booleans are always finite
    t = true(size(this));
else
    t = isfinite(double(this));
end
