function angleInRadians = deg2rad(angleInDegrees)
% DEG2RAD Convert angles from degrees to radians.
%   DEG2RAD(X) converts angle units from degrees to radians for each
%   element of X.
%
%   See also RAD2DEG.

% Copyright 2015 The MathWorks, Inc.

if isfloat(angleInDegrees)
    angleInRadians = (pi/180) * angleInDegrees;
else
    error(message('MATLAB:deg2rad:nonFloatInput'))
end
