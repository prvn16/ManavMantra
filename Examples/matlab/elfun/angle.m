function p = angle(h)
%ANGLE  Phase angle.
%   ANGLE(H) returns the phase angles, in radians, of a matrix with
%   complex elements.  
%
%   Class support for input X:
%      float: double, single
%
%   See also ABS, UNWRAP.

%   Copyright 1984-2010 The MathWorks, Inc. 

p = atan2(imag(h), real(h));

