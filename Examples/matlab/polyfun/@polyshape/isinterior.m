function [INPOLY, ONPOLY] = isinterior(pshape, varargin)
% ISINTERIOR  Query if a point is inside or on the boundary of a polyshape
%
% INPOLY = ISINTERIOR(pshape, X, Y) returns a logical vector whose elements
% are true when the corresponding 2-D points represented in the vectors X 
% and Y are either inside of a polyshape or on a boundary of a polyshape.
%
% [INPOLY, ONPOLY] = ISINTERIOR(pshape, X, Y) returns an additional vector 
% whose elements are true if the corresponding query points are on a 
% boundary of pshape. 
%
% [INPOLY, ONPOLY] = ISINTERIOR(pshape, P) represents the query points as 
% a 2-column matrix. The first column contains the x-coordinates of the 
% query points, and the second column contains the y-coordinates.
%
% See also inpolygon, polyshape, intersect
%
% Copyright 2016-2017 The MathWorks, Inc.

%---code below this line---
narginchk(2, 3);
polyshape.checkScalar(pshape);
%polyshape.checkEmpty(pshape);

param.allow_inf = true;
param.allow_nan = true;
param.one_point_only = false;
param.errorOneInput = 'MATLAB:polyshape:queryPoint1';
param.errorTwoInput = 'MATLAB:polyshape:queryPoint2';
param.errorValue = 'MATLAB:polyshape:queryPointValue';
[X, Y] = polyshape.checkPointArray(param, varargin{:});

if isEmptyShape(pshape)
    INPOLY = false(numel(X),1);
    ONPOLY = false(numel(X),1);
    return;
end

%boundary is closed
[xv, yv] = boundary(pshape);
xv(end+1) = NaN;
yv(end+1) = NaN;

%pm.the_scale = 1.0e14/(max_bound+max_value);
[xlim, ylim] = boundingbox(pshape);
maxD = max(abs([xlim ylim]));
maxW = max(xlim(2)-xlim(1), ylim(2)-ylim(1));
tol = (maxD+maxW)*1.0e-12;

[in, on] = check_inpolygon(X, Y, xv, yv, tol);

INPOLY = reshape(in, size(X));
ONPOLY = reshape(on, size(X));
end

%----------------------------------------------
function [in, on] = check_inpolygon(x,y,xv,yv, tol)
% copied from inpolygon.m with some modification

x = x(:).';
y = y(:).';

Nv = length(xv);
Np = length(x);
x = x(ones(Nv,1),:);
y = y(ones(Nv,1),:);

% Compute scale factors for eps that are based on the original vertex 
% locations. This ensures that the test points that lie on the boundary 
% will be evaluated using an appropriately scaled tolerance.
% (m and mp1 will be reused for setting up adjacent vertices later on.)
m = 1:Nv-1;
mp1 = 2:Nv;
avx = abs(0.5*(  xv(m,:) + xv(mp1,:)));
avy = abs(0.5*(yv(m,:)+yv(mp1,:)));
scaleFactor = max(avx(m), avy(m));
scaleFactor = max(scaleFactor, avx(m,:).*avy(m,:) );
% Translate the vertices so that the test points are
% at the origin.
xv = xv(:,ones(1,Np)) - x;
yv = yv(:,ones(1,Np)) - y;

% Compute the quadrant number for the vertices relative
% to the test points.
posX = xv > 0;
posY = yv > 0;
negX = ~posX;
negY = ~posY;
quad = (negX & posY) + 2*(negX & negY) + 3*(posX & negY);

% Ignore crossings between distinct edge loops that are separated by NaNs
nanidx = isnan(xv) | isnan(yv);
quad(nanidx) = NaN;
% Compute the sign() of the cross product and dot product
% of adjacent vertices.
theCrossProd = xv(m,:) .* yv(mp1,:) - xv(mp1,:) .* yv(m,:);
signCrossProduct = sign(theCrossProd);


% Adjust values that are within epsilon of the polygon boundary.
% Making epsilon larger will treat points close to the boundary as 
% being "on" the boundary. A factor of 3 was found from experiment to be
% a good margin to hedge against roundoff.

%scaledEps = scaleFactor*eps*3;
%idx = abs(theCrossProd) < scaledEps;
idx = abs(theCrossProd) < tol;
signCrossProduct(idx) = 0;

dotProduct = xv(m,:) .* xv(mp1,:) + yv(m,:) .* yv(mp1,:);

% Compute the vertex quadrant changes for each test point.
diffQuad = diff(quad);

% Fix up the quadrant differences.  Replace 3 by -1 and -3 by 1.
% Any quadrant difference with an absolute value of 2 should have
% the same sign as the cross product.
idx = (abs(diffQuad) == 3);
diffQuad(idx) = -diffQuad(idx)/3;
idx = (abs(diffQuad) == 2);
diffQuad(idx) = 2*signCrossProduct(idx);

% Find the inside points.
% Ignore crossings between distinct loops that are separated by NaNs
nanidx = isnan(diffQuad);
diffQuad(nanidx) = 0;
in = (sum(diffQuad) ~= 0);

% Find the points on the polygon.  If the cross product is 0 and
% the dot product is nonpositive anywhere, then the corresponding
% point must be on the contour.
on = any((signCrossProduct == 0) & (dotProduct <= 0));

in = in | on;
end