function PG = rotate(pshape, theta, center)
% ROTATE Rotate a polyshape
%
% PG = ROTATE(pshape, theta) rotates the input polyshape by theta degrees
% with respect to the point (0,0). Positive values of theta rotate 
% counter-clockwise, and negative values rotate clockwise. When the input 
% polyshape is an array, each element of the array is rotated.
%
% PG = ROTATE(pshape, theta, refpoint) rotates the input polyshape with 
% respect to the reference point refpoint. refpoint is a two-element row
% vector whose first element is the x-coordinate of the reference point
% and second element is the y-coordinate. refpoint is [0 0] by default.
%
% See also scale, translate, union, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

if nargin < 2
    error(message('MATLAB:polyshape:rotateAngleMissing'));
end

n = polyshape.checkArray(pshape);

theta = polyshape.checkScalarValue(theta, 'MATLAB:polyshape:rotateAngleError');
if theta >= 360 || theta <= -360
    theta = rem(theta, 360);
end

if nargin == 2
    center = [0 0];
else
    param.allow_inf = false;
    param.allow_nan = false;
    param.one_point_only = true;
    param.errorOneInput = 'MATLAB:polyshape:rotateCenter';
    param.errorTwoInput = 'MATLAB:polyshape:rotateCenter';
    param.errorValue = 'MATLAB:polyshape:rotateCenterValue';
    [X, Y] = polyshape.checkPointArray(param, center);
    center = [X Y];
end

PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        continue;
    end
    PG(i).Underlying = rotate(pshape(i).Underlying, theta, center);
end
