%ISSCALINGBINARYPOINT Determine whether numerictype object has binary point scaling
%   ISSCALINGBINARYPOINT(T) returns 1 when numerictype object T has binary point scaling
%   or trivial slope and bias scaling.  Otherwise it returns 0. Slope and bias scaling is
%   trivial when the slope is an integer power of 2 and the bias is zero.
%
%   See also EMBEDDED.NUMERICTYPE/ISFIXED,
%            EMBEDDED.NUMERICTYPE/ISFLOAT,
%            EMBEDDED.NUMERICTYPE/ISBOOLEAN,
%            EMBEDDED.NUMERICTYPE/ISDOUBLE,
%            EMBEDDED.NUMERICTYPE/ISSINGLE,
%            EMBEDDED.NUMERICTYPE/ISSCALEDDOUBLE,
%            EMBEDDED.NUMERICTYPE/ISSCALEDTYPE,
%            EMBEDDED.NUMERICTYPE/ISSCALINGSLOPEBIAS,
%            EMBEDDED.NUMERICTYPE/ISSCALINGUNSPECIFIED,
%            EMBEDDED.FI/ISSCALINGBINARYPOINT

%   Copyright 2010 The MathWorks, Inc.
