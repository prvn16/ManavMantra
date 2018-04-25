function tri = triangulation(pshape)
% TRIANGULATION Construct a 2D triangulation object from polyshape
%
% tri = TRIANGULATION(pshape) triangulates a polyshape and returns a 2-D
% triangulation object.
%
% Example:
%  rect = polyshape([0 0 1 1], [0 3 3 0]);
%  tri = triangulation(rect);
%
% See also triplot, regions, holes, polyshape, triangulation

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkScalar(pshape);
polyshape.checkEmpty(pshape);
[f, v] = tristrip(pshape.Underlying);
warning('off', 'MATLAB:triangulation:PtsNotInTriWarnId');
tri = triangulation(f, v);
warning('on', 'MATLAB:triangulation:PtsNotInTriWarnId');
