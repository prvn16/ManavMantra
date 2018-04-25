function angleInDegrees = rad2deg(angleInRadians)
% RAD2DEG Convert angles from radians to degrees.
%   RAD2DEG(X) converts angle units from radians to degrees for each
%   element of X.
%
%   See also DEG2RAD.

% Copyright 2015 The MathWorks, Inc.

if isfloat(angleInRadians)
    angleInDegrees = (180/pi) * angleInRadians;
else
    error(message('MATLAB:rad2deg:nonFloatInput'))
end
