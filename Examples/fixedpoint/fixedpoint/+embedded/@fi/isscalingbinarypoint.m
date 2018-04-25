%ISSCALINGBINARYPOINT Determine whether fi object has binary point scaling
%   ISSCALINGBINARYPOINT(T) returns 1 when fi object T has binary point scaling or
%   trivial slope and bias scaling.  Otherwise it returns 0. Slope and bias scaling
%   is trivial when the slope is an integer power of 2 and the bias is zero.
%
%   See also EMBEDDED.FI/ISFIXED,
%            EMBEDDED.FI/ISFLOAT,
%            EMBEDDED.FI/ISDOUBLE,
%            EMBEDDED.FI/ISSINGLE,
%            EMBEDDED.FI/ISBOOLEAN,
%            EMBEDDED.FI/ISSCALEDDOUBLE,
%            EMBEDDED.FI/ISSCALEDTYPE,
%            EMBEDDED.FI/ISSCALINGSLOPEBIAS,
%            EMBEDDED.FI/ISSCALINGUNSPECIFIED

%   Copyright 2010-2012 The MathWorks, Inc.
