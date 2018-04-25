function [in,on] = inpolygon(points_x,points_y,polygon_x,polygon_y) %#codegen

% Copyright 2015 The MathWorks, Inc.

if isempty(coder.target)
    [in,on] = inpolygon(points_x,points_y,polygon_x,polygon_y);
    return
end

[inputSize,points_x,points_y,polygon_x,polygon_y] = ...
    validateInputs(points_x,points_y,polygon_x,polygon_y);

% Exit early if all the points are outside of the polygon
[TF,mask] = areAllPointsOutsidePolygon(points_x,points_y,polygon_x,polygon_y);
if TF
    in = false(inputSize);
    on = false(inputSize);
    return
end

[closedPolygon_x,closedPolygon_y] = closeLoops(polygon_x,polygon_y);

% Issue a warning if the bounding box is outside the modeling world that 
% we can accurately represent.
xRange = max(closedPolygon_x) - min(closedPolygon_x);
yRange = max(closedPolygon_y) - min(closedPolygon_y);
minSafeLimit = 1.0e-15;
maxSafeLimit = 1.0e150;

if xRange < minSafeLimit || yRange < minSafeLimit
    coder.internal.warning('MATLAB:inpolygon:ModelingWorldLower');
end
if xRange > maxSafeLimit || yRange > maxSafeLimit
    coder.internal.warning('MATLAB:inpolygon:ModelingWorldUpper');
end

% Remove points that we already know can't be in the polygon
inBoundsPointsIdx = find(mask);
inBoundsPoints_x = points_x(inBoundsPointsIdx);
inBoundsPoints_y = points_y(inBoundsPointsIdx);

% Check whether points are inside, on, or outisde polygon
[in,on] = isInPolygon(inBoundsPoints_x,inBoundsPoints_y, ...
                      closedPolygon_x,closedPolygon_y);

onMask = mask;
onMask(inBoundsPointsIdx(~on)) = 0;
on = reshape(onMask,inputSize);

mask(inBoundsPointsIdx(~in)) = 0;
in = reshape(mask,inputSize);

%--------------------------------------------------------------------------
function [inputSize,pts_x,pts_y,poly_x,poly_y] = validateInputs(x,y,xv,yv)

coder.internal.prefer_const(x,y,xv,yv);

validateattributes(x,{'numeric'},{'vector'},mfilename,'X',1)
validateattributes(y,{'numeric'},{'vector'},mfilename,'Y',1)
validateattributes(xv,{'numeric'},{'vector'},mfilename,'XV',1)
validateattributes(yv,{'numeric'},{'vector'},mfilename,'YV',1)

% Forbid mixed types as it leads to other errors down the chain
% except if one is double and the other single
type = class(x);
xIsfloat = isfloat(x);
coder.internal.errorIf(~isa(y,type) && ~(xIsfloat && isfloat(y)), ...
    'images:validate:differentClassMatrices','X','Y')
coder.internal.errorIf(~isa(xv,type) && ~(xIsfloat && isfloat(xv)), ...
    'images:validate:differentClassMatrices','X','XV')
coder.internal.errorIf(~isa(yv,type) && ~(xIsfloat && isfloat(yv)), ...
    'images:validate:differentClassMatrices','X','YV')

coder.internal.errorIf(numel(x) ~= numel(y), ...
    'images:validate:unequalNumberOfElements','X','Y')
coder.internal.errorIf(numel(xv) ~= numel(yv), ...
    'images:validate:unequalNumberOfElements','XV','YV')

inputSize = size(x);
pts_x = convertToColumnVector(x);
pts_y = convertToColumnVector(y);
poly_x = convertToColumnVector(xv);
poly_y = convertToColumnVector(yv);

%--------------------------------------------------------------------------
function y = convertToColumnVector(x)

if size(x,2) ~= 1
    y = x';
else
    y = x;
end

%--------------------------------------------------------------------------
function [TF,mask] = areAllPointsOutsidePolygon(points_x,points_y,polygon_x,polygon_y)

mask = (points_x >= min(polygon_x)) & ...
    (points_x <= max(polygon_x)) & ...
    (points_y >= min(polygon_y)) & ...
    (points_y <= max(polygon_y));

TF = ~any(mask);

%--------------------------------------------------------------------------
function [closedPolygon_x,closedPolygon_y] = closeLoops(polygon_x,polygon_y)

xNaNPositions = isnan(polygon_x);
yNaNPositions = isnan(polygon_y);

if ~any(xNaNPositions | yNaNPositions)
    % Simply-connected polygon
    
    % Return if polygon has fewer than 3 elements
    if numel(polygon_x) < 3
        closedPolygon_x = polygon_x;
        closedPolygon_y = polygon_y;
        return
    end
    
    % If the polygon is open, then close it
    if (polygon_x(1) ~= polygon_x(end) || polygon_y(1) ~= polygon_y(end))
        closedPolygon_x = [polygon_x; polygon_x(1)];
        closedPolygon_y = [polygon_y; polygon_y(1)];
    else
        closedPolygon_x = polygon_x;
        closedPolygon_y = polygon_y;
    end
else
    % Multiply-connected polygon
    
    % Check consistency of loop definitions
    coder.internal.errorIf( any(xNaNPositions ~= yNaNPositions), ...
        'MATLAB:inpolygon:InvalidLoopDef')
    
    [newPolygon_x,newPolygon_y] = ...
        removeRedundantNaNs(polygon_x,polygon_y,xNaNPositions);
    
    % Check for loops that have less than three vertices.
    NaNLocations = find( isnan(newPolygon_x) );
    
    % Close any open loops.    
    % First, figure out how many closures do we need to make
    % and grow the vectors to accommodate.
    startIdx = coder.internal.indexInt(1);
    growthLength = 0;
    numLoops = numel(NaNLocations);
    
    for k = 1:numLoops
        endIdx = coder.internal.indexMinus(NaNLocations(k),1);
        isLoopClosed = newPolygon_x(startIdx) == newPolygon_x(endIdx) ...
                    && newPolygon_y(startIdx) == newPolygon_y(endIdx);
        growthLength = growthLength + double(~isLoopClosed);
        startIdx = coder.internal.indexPlus(endIdx,2);
    end
    
    if (growthLength > 0)
        newLength = numel(newPolygon_x) + growthLength;
        closedPolygon_x = coder.nullcopy(zeros(newLength,1,'like',newPolygon_x));
        closedPolygon_y = coder.nullcopy(zeros(newLength,1,'like',newPolygon_y));
        
        startIdx = coder.internal.indexInt(1);
        idxOffset = coder.internal.indexInt(0);
        
        for k = 1:numLoops
            endIdx = coder.internal.indexMinus(NaNLocations(k),1);
            closedPolygon_x(idxOffset+(startIdx:endIdx)) = newPolygon_x(startIdx:endIdx);
            closedPolygon_y(idxOffset+(startIdx:endIdx)) = newPolygon_y(startIdx:endIdx);
            isLoopClosed = newPolygon_x(startIdx) == newPolygon_x(endIdx) ...
                        && newPolygon_y(startIdx) == newPolygon_y(endIdx);
            if ~isLoopClosed
                idxOffset = coder.internal.indexPlus(idxOffset,1);
                closedPolygon_x(idxOffset+endIdx) = newPolygon_x(startIdx);
                closedPolygon_y(idxOffset+endIdx) = newPolygon_y(startIdx);
            end
            closedPolygon_x(idxOffset+endIdx+1) = coder.internal.nan;
            closedPolygon_y(idxOffset+endIdx+1) = coder.internal.nan;
            startIdx = coder.internal.indexPlus(endIdx,2);
        end
    else
        % Remove last element
        closedPolygon_x = newPolygon_x(1:end-1);
        closedPolygon_y = newPolygon_y(1:end-1);
    end
end

%--------------------------------------------------------------------------
% Remove redundant NaN separators if they are present
% Also remove starting NaN if present
% Add a trailing NaN to avoid the special case
function [newPolygon_x,newPolygon_y] = removeRedundantNaNs(polygon_x, ...
                                                    polygon_y,NaNPositions)

shiftedXNaNPositions = [true; NaNPositions(1:end-1)];
redundantNaNPositions = NaNPositions & shiftedXNaNPositions;

addTrailingNaN = ~isnan(polygon_x(end));

numberOfVertices = numel(polygon_x);
newNumberOfVertices = numel(polygon_x) - nnz(redundantNaNPositions) ...
                    + double(addTrailingNaN);

newPolygon_x = coder.nullcopy(zeros(newNumberOfVertices,1,'like',polygon_x));
newPolygon_y = coder.nullcopy(zeros(newNumberOfVertices,1,'like',polygon_y));

p = coder.internal.indexInt(1);
for k = 1:numberOfVertices
    if ~redundantNaNPositions(k)
        % Copy the vertices while leaving out redundant NaNs
        newPolygon_x(p) = polygon_x(k);
        newPolygon_y(p) = polygon_y(k);
        p = coder.internal.indexPlus(p,1);
    end
end

if addTrailingNaN
    newPolygon_x(p) = coder.internal.nan;
    newPolygon_y(p) = coder.internal.nan;
end

%--------------------------------------------------------------------------
% Core algorithm.
% Expects the polygon vertices to be pre-processed.
%   @in:  test points
%         polygon vertices
%   @out: logical vector indicating whether point lies inside polygon
%         logical vector indicating whether point lies on polygon contour
function [in,on] = isInPolygon(points_x,points_y,polygon_x,polygon_y)

% Translate the vertices so that the test points are at the origin
[translatedPolygon_x,translatedPolygon_y] = translateVertices( ...
    polygon_x,polygon_y,points_x,points_y);

% Compute epsilon values within which a point 
% is considered to be on the polygon
scaledEps = computeScaledEps(polygon_x,polygon_y);

% The sign of the cross product and the dot product between adjacent,
% translated polygon vertices indicate whether a point lies inside, on, or
% outside of the polygon
[signCrossProd,dotProd] = computeCrossAndDotProducts( ...
    translatedPolygon_x,translatedPolygon_y,scaledEps);

% Find the points that lie stricly inside the polygon
in = findInsidePoints(translatedPolygon_x,translatedPolygon_y,signCrossProd);

% Find the points that lie on the contour and set these points as also
% being inside the polygon
[on,in] = findBoundaryPoints(signCrossProd,dotProd,in);

%--------------------------------------------------------------------------
% Translate the vertices so that the test points are
% at the origin.
%   @in:  polygon vertices (length M), test points (length N)
%   @out: translated polygon vertices (size MxN)
function [transPoly_x,transPoly_y] = translateVertices(polygon_x,polygon_y,points_x,points_y)

numPoints   = numel(points_x);
numVertices = numel(polygon_x);

transPoly_x = coder.nullcopy(zeros(numVertices,numPoints,'like',polygon_x));
transPoly_y = coder.nullcopy(zeros(numVertices,numPoints,'like',polygon_y));

for p = 1:numPoints
    for v = 1:numVertices
        transPoly_x(v,p) = polygon_x(v) - points_x(p);
        transPoly_y(v,p) = polygon_y(v) - points_y(p);
    end
end

%--------------------------------------------------------------------------
% Compute scale factors for eps that are based on the original vertex 
% locations. This ensures that the test points that lie on the boundary 
% will be evaluated using an appropriately scaled tolerance.
%   @in:  polygon vertices
%   @out: scaled epsilon values
function scaledEps = computeScaledEps(polygon_x,polygon_y)

numVertices = numel(polygon_x);
scaledEps = coder.nullcopy(zeros(numVertices-1,1,'like',polygon_x));

for k = 1:numVertices-1
    avx = abs(0.5*( polygon_x(k) + polygon_x(k+1) ));
    avy = abs(0.5*( polygon_y(k) + polygon_y(k+1) ));
    factor = max(avx,avy);
    factor = max(factor,avx*avy);
    % These epsilon values are used to treat points close to the boundary
    % as on the boundary.
    % Making epsilon larger will treat points close to the boundary as
    % being "on" the boundary. A factor of 3 was found from experiment to 
    % be a good margin to hedge against roundoff.
    scaledEps(k) = factor*eps*3;
end

%--------------------------------------------------------------------------
% Compute the sign() of the cross product and dot product
% of adjacent vertices.
%   @in:  translated polygon vertices
%   @out: sign of cross products and dot products between adjacents vertices
function [signCrossProd,dotProd] = computeCrossAndDotProducts(transPoly_x,transPoly_y,scaledEps)

[numVertices,numPoints] = size(transPoly_x);
signCrossProd = coder.nullcopy(zeros(numVertices-1,numPoints));
dotProd       = coder.nullcopy(zeros(numVertices-1,numPoints,'like',transPoly_x));

for p = 1:numPoints
    for v = 1:numVertices-1
        x1 = transPoly_x(v,p);
        x2 = transPoly_x(v+1,p);
        y1 = transPoly_y(v,p);
        y2 = transPoly_y(v+1,p);
        
        dotProd(v,p) = x1 * x2 + y1 * y2;
        crossProd    = y2 * x1 - x2 * y1;
        signCrossProd(v,p) = sign(crossProd);
        
        % Adjust values that are within epsilon of the polygon boundary.
        if abs(crossProd) < scaledEps(v)
            signCrossProd(v,p) = 0;
        end
    end
end

%--------------------------------------------------------------------------
% Find the inside points.
%   @in:  translated polygon vertices
%         sign of cross products b/w adjacent vertices
%   @out: logical vector indicated whether test points lie in polygon
function in = findInsidePoints(transPolygon_x,transPolygon_y,signCrossProd)

[numVertices,numPoints] = size(transPolygon_x);
in = coder.nullcopy(false(numPoints,1));

for p = 1:numPoints
    
    sumDiffQuad = 0;
    
    % Compute the vertex quadrant changes for each test point.
    for v = 1:numVertices-1
        % Vertex v
        quadNum1 = computeQuadrantNumber(transPolygon_x(v,p),transPolygon_y(v,p));
        
        % Vertex v+1
        quadNum2 = computeQuadrantNumber(transPolygon_x(v+1,p),transPolygon_y(v+1,p));
        
        diffQuad = quadNum2 - quadNum1;
        
        % Fix up the quadrant differences.  Replace 3 by -1 and -3 by 1.
        % Any quadrant difference with an absolute value of 2 should have
        % the same sign as the cross product.
        if (abs(diffQuad) == 3)
            diffQuad = -diffQuad/3;
        elseif (abs(diffQuad) == 2)
            diffQuad = 2*signCrossProd(v,p);
        elseif isnan(diffQuad)
            % Ignore crossings b/w distinct loops that are separated by NaNs
            diffQuad = 0;
        end
        
        sumDiffQuad = sumDiffQuad + diffQuad;
    end
    
    in(p) = (sumDiffQuad ~= 0);
end

%--------------------------------------------------------------------------
% Compute the quadrant number for the vertices relative
% to the test points.
%   @in:  a vertex with translated coordinates (x,y)
%   @out: quadrant number for that vertex
function quadrantNumber = computeQuadrantNumber(x,y)

isPositive_x = x > 0;
isPositive_y = y > 0;

quadrantNumber = double(~isPositive_x & isPositive_y) ...
                + 2*double(~isPositive_x & ~isPositive_y) ...
                + 3*double(isPositive_x & ~isPositive_y);

% Ignore crossings between distinct edge loops that are separated by NaNs
if (isnan(x) || isnan(y))
    quadrantNumber = coder.internal.nan;
end

%--------------------------------------------------------------------------
% Find the points on the polygon.
% If the cross product is 0 and the dot product is nonpositive anywhere, 
% then the corresponding point must be on the contour.
% If the point is on the contour, then we say it's also inside.
%   @in:  sign of the cross products
%         dot products
%         logical vector indicating whether a point is inside the polygon
%   @out: logical vector indicating whether a point is on the contour
%         rectified "in" vector
function [on,in] = findBoundaryPoints(signCrossProd,dotProd,in)

[numProds,numPoints] = size(signCrossProd);
on = false(numPoints,1);

for p = 1:numPoints
    for k = 1:numProds
        if (signCrossProd(k,p) == 0) && (dotProd(k,p) <= 0)
            on(p) = true;
            in(p) = true;
            break
        end
    end
end
