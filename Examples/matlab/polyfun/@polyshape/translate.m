function PG = translate(pshape, varargin)
% TRANSLATE Translate a polyshape
%
% PG = TRANSLATE(pshape, V) translates a polyshape according to a 
% two-element row vector V. The first element of V is the translation 
% distance in the x direction, and the second element is the translation 
% distance in the y direction. Positive values in V translate right and up, 
% and negative values translate left and down. When pshape is an array of 
% polyshapes, each element of pshape is translated according to V.
%
% PG = TRANSLATE(pshape, x, y) specifies the x and y translation distances 
% as separate arguments.
%
% See also scale, rotate, polybuffer, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2, 3);

n = polyshape.checkArray(pshape);

param.allow_inf = false;
param.allow_nan = false;
param.one_point_only = true;
param.errorOneInput = 'MATLAB:polyshape:transVector1';
param.errorTwoInput = 'MATLAB:polyshape:transVector2';
param.errorValue = 'MATLAB:polyshape:transVectorValue';
[X, Y] = polyshape.checkPointArray(param, varargin{:});
V = [X Y];

PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        continue;
    end
    PG(i).Underlying = translate(pshape(i).Underlying, V);
end
