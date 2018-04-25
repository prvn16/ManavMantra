function  [xt,yt] = xycrull(t)
%XYCRULL Function that returns the coordinate functions
%   for the eccentric ellipse that generates the cruller
%   in the MATLAB script CRULLER.

%   C. Henry Edwards, University of Georgia. 6/20/93.
%
%   Copyright 1984-2015 The MathWorks, Inc.

xt = 3*cos(t);
yt = sin(t);

