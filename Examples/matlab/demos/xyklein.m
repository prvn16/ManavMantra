function [xt,yt] = xyklein(t)
%XYKLEIN Coordinate functions for the figure-8 that
%   generates the Klein bottle in KLEIN1.

%   C. Henry Edwards, University of Georgia. 6/20/93.
%
%   Copyright 1984-2014 The MathWorks, Inc.

xt = sin(t);
yt = sin(2*t);
