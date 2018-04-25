function PG = addboundary(pshape, varargin)
% ADDBOUNDARY Add boundaries to a polyshape
%
% PG = ADDBOUNDARY(pshape, X, Y) returns a polyshape with additional 
% boundaries defined by the x- and y-coordinates in X and Y. X and Y must 
% have the same length. 
%
% PG = ADDBOUNDARY(pshape, P) adds boundaries defined in the Nx2 matrix P, 
% whose first column contains the x-coordinates of the boundaries and second 
% column contains the corresponding y-coordinates.
%
% PG = ADDBOUNDARY(pshape, {X1, X2, ... Xn}, {Y1, Y2, ... Yn}) adds n
% boundaries whhere Xi contains x-coordinates and Yi contains y-coordinates
% for the ith boundary.
%
% PG = ADDBOUNDARY(..., 'SolidBoundaryOrientation', DIR) specifies the 
% direction convention for determining solid versus hole boundaries. DIR 
% can be one of the following:
%  'auto' (default) - Automatically determine direction convention
%  'cw' - Clockwise vertex direction defines solid boundaries
%  'ccw' - Counterclockwise vertex direction defines solid boundaries
%
% This name-value pair is typically only specified when creating a polyshape 
% from data that was produced by other software that uses a particular 
% convention.  
%
% PG = ADDBOUNDARY(..., 'Simplify', tf) specifies how ill-defined polyshape 
% boundaries are handled. tf can be one of the following:
%  true (default) - Automatically alter boundary vertices to create a 
% well-defined polygon.
%  false - Do not alter boundary vertices even though the polyshape is 
% ill-defined. This may lead to inaccurate or unexpected results.
%
% See also polyshape, rmboundary, ishole, intersect

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2, inf);
polyshape.checkScalar(pshape);
PG = polyshape();
param = struct;
param.checkWindingNumber = false;
param.parameterError = 'MATLAB:polyshape:addBoundaryParameter';
[X, Y, tc, simpl] = polyshape.checkInput(param, varargin{:});
PG.Underlying = addboundary(pshape.Underlying, X, Y, tc, uint32(0));
if simpl == "true" || (simpl == "default" && pshape.SimplifyState >= 0)
    PG = checkAndSimplify(PG, true);
else
    PG.SimplifyState = -1;
end
