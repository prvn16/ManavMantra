function PG = scale(pshape, s, center)
% SCALE Scale the polyshape by factor
%
% PG = SCALE(pshape, s) scales the input polyshape by a factor s with 
% respect to the point (0,0). If s is a scalar, then s is the scaling 
% factor in both the x and y direction. If s is a two-element row vector, 
% then the first element is the scaling factor in the x direction, and the 
% second element is the scaling factor in the y direction. The elements of 
% s must be positive. When the input polyshape is an array, each element of
% the array is scaled.
%
% PG = SCALE(pshape, s, refpoint) scales the input polyshape with respect 
% to the reference point refpoint. refpoint is a two-element row vector 
% whose first element is the x-coordinate of the reference point and second 
% element is the y-coordinate. refpoint is [0 0] by default.
%
% See also translate, rotate, centroid, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

if nargin < 2
    error(message('MATLAB:polyshape:scaleFactorMissing'));
end

n = polyshape.checkArray(pshape);

if nargin == 2
    center = [0 0];
else
    param.allow_inf = false;
    param.allow_nan = false;
    param.one_point_only = true;
    param.errorOneInput = 'MATLAB:polyshape:scaleCenter';
    param.errorTwoInput = 'MATLAB:polyshape:scaleCenter';
    param.errorValue = 'MATLAB:polyshape:scaleCenterValue';
    [X, Y] = polyshape.checkPointArray(param, center);
    center = [X Y];
end

if numel(s) == 0 || numel(s) > 2 || (iscolumn(s) && numel(s) == 2)
    error(message('MATLAB:polyshape:scaleInputsError'));
end

if ~isnumeric(s) || ~isreal(s) || any(~isfinite(s)) || any(isnan(s)) || any(s <= 0)
    error(message('MATLAB:polyshape:scaleFactorValue'));
elseif issparse(s)
    error(message('MATLAB:polyshape:sparseError'));
else
    ds = double(s);
end

PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        continue;
    end
    PG(i).Underlying = scale(pshape(i).Underlying, ds, center);
end
