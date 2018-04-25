function [adaptedX,adaptedY,adaptedZ] = adaptXYZ(X,Y,Z,M) %#codegen
% adaptXYZ Chromatic adaptation of XYZ tristimulous for MATLAB-to-C codegen
%
%   Chromatically adapt XYZ color values based on
%   a source white point and a destination white point.
%
%   M is a chromatic adaptation matrix computed with
%   XYZChromaticAdaptationTransform. It depends on a
%   source white and a reference destination white.

%   Copyright 2015 The MathWorks, Inc.
 
adaptedX = M(1,1)*X + M(1,2)*Y + M(1,3)*Z;
adaptedY = M(2,1)*X + M(2,2)*Y + M(2,3)*Z;
adaptedZ = M(3,1)*X + M(3,2)*Y + M(3,3)*Z;
