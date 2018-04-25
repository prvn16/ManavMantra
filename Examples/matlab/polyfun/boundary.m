function [K, varargout] = boundary(varargin)
%BOUNDARY Boundary of a set of points in 2D/3D space
%   K = BOUNDARY(X,Y) returns a single conforming boundary around the points 
%   (X,Y). X and Y are column vectors of equal size that specify the coordinates. 
%   K is a vector of point indices that represents a compact boundary around 
%   the points. Unlike the convex hull, the boundary can shrink towards the 
%   interior of the hull to envelop the points.
%
%   K = BOUNDARY(X,Y,Z) returns a single conforming boundary around the 
%   points (X,Y,Z). X, Y and Z are column vectors of equal size that specify 
%   the coordinates. K is a triangulation that represents a compact boundary 
%   around the points. K is of size mtri-by-3, where mtri is the number of 
%   triangular facets. That is, each row of K is a triangle defined in terms 
%   of the point indices. Unlike the convex hull, the boundary can shrink 
%   towards the interior of the hull to envelop the points.
%
%   K = BOUNDARY(P) returns the 2D/3D boundary of the points P. This syntax 
%   is equivalent to the (X,Y) and (X,Y,Z) syntaxes where the columns of P 
%   are X,Y, or X,Y,Z respectively.
%
%   K = BOUNDARY(...,S) provides an option of specifying the shrink factor S.
%   The scalar S has a value in the range 0<=S<=1. Setting S to 0 gives the
%   convex hull, while setting S to 1 gives a compact boundary that envelops
%   the points. The default shrink factor is 0.5.
%
%   [K,V] = BOUNDARY(...) returns the boundary K and the corresponding 
%   area/volume V bounded by K.
%
%   Example 1:
%      x = rand(30,1);
%      y = rand(30,1);
%      k = boundary(x,y);
%      plot(x,y, '.', x(k), y(k), '-r')
%      axis equal
%      % Repeat this example by separately passing 
%      % a shrink factor of 0 and then 1 to the
%      % boundary function.
%
%   Example 2:
%      x = rand(25,1);
%      y = rand(25,1);
%      z = rand(25,1);
%      k = boundary(x,y,z,0.8);
%      trisurf(k,x,y,z, 'Facecolor','cyan','FaceAlpha',0.8); axis equal;
%      hold on
%      plot3(x,y,z,'.r')
%
%   See also alphaShape, triangulation, delaunayTriangulation, TRISURF,
%            CONVHULL

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(1,4);
nargoutchk(0,2);
K = [];
if nargout == 2
    varargout{1} = 0; 
end
[P, S] = sanityCheckInput(varargin{:});
preMergeSize = size(P,1);
[~, I, ~] = unique(P,'first','rows');
postMergeSize = length(I);
if (preMergeSize > postMergeSize)
    % Undo the sort to preserve 
    % the ordering of points
    sorted_I = sort(I);
    P = P(sorted_I,:);      
end
shp = alphaShape(P,Inf);
if shp.numRegions() == 0
  return;
end
P = shp.Points;
if size(P,2) == 2
    areavol = shp.area();
else
    areavol = shp.volume();
end
Acrit = shp.criticalAlpha('one-region');
spec = shp.alphaSpectrum();
idx = find(spec==Acrit);
subspec = spec(1:idx);
subspec = flipud(subspec);
idx = max(ceil((1-S)*numel(subspec)),1);
alphaval = subspec(idx);
shp.Alpha = alphaval;
shp.HoleThreshold = areavol;
bf  = shp.boundaryFacets();
if size(P,2) == 2
  bf = bf';
  bf = bf(:);
  numv = numel(bf);
  idx = (1:2:numv)';
  bf = bf(idx);
  bf(end+1) = bf(1);
end
K = bf;
if (preMergeSize > postMergeSize)
    K = sorted_I(K);   
end
if nargout == 2
   if size(P,2) == 2
    varargout{1} = shp.area();
   else
    varargout{1} = shp.volume();
   end    
end
end

function [P, S] = sanityCheckInput(varargin)
    S = 0.5;
    if nargin == 1
        P = varargin{1};
        sanityCheckPoints(P);
    elseif nargin == 2
        [arg1, arg2] = deal(varargin{:});
        if  isequal(size(arg1),size(arg2)) && isnumeric(arg1) && isnumeric(arg2)
            P = checkAndConcatVectors(arg1, arg2);
        elseif (~isscalar(arg1) && isscalar(arg2))
            P = arg1;
            sanityCheckPoints(P);
            S = arg2;                        
        else
            error(message('MATLAB:boundary:InvalidInput'));
        end
    elseif nargin == 3
        [arg1, arg2, arg3] = deal(varargin{:});
        if isequal(size(arg1),size(arg2)) && isequal(size(arg2),size(arg3)) && isnumeric(arg1) && isnumeric(arg2) && isnumeric(arg3)
            P = checkAndConcatVectors(arg1, arg2, arg3);
        elseif isequal(size(arg1),size(arg2)) && isnumeric(arg1) && isnumeric(arg2) && isscalar(arg3)
            P = checkAndConcatVectors(arg1, arg2);
            S = arg3;
        else
            error(message('MATLAB:boundary:InvalidInput'));
        end
    elseif nargin == 4 
        S = varargin{end};
        [arg1, arg2, arg3] = deal(varargin{1:(end-1)});
        if isequal(size(arg1),size(arg2)) && isequal(size(arg2),size(arg3)) && isnumeric(arg1) && isnumeric(arg2) && isnumeric(arg3)
            P = checkAndConcatVectors(arg1, arg2, arg3);
        else
            error(message('MATLAB:boundary:InvalidInput'));
        end
    end
    sanityCheckShrink(S);  
end

function P = checkAndConcatVectors(varargin)
    P = [];
    for i = 1 : nargin
        a = varargin{i};
        if isequal(a, [])  %ones(0, 1) is accepted though
            error(message('MATLAB:boundary:EmptyInpPtsErrId'));
        elseif ~iscolumn(a)
            error(message('MATLAB:boundary:NonColVecInpPtsErrId'));
        end
        P = [P a];
    end
end

function sanityCheckPoints(P)
    if isequal(P, [])
        error(message('MATLAB:boundary:EmptyInpPtsErrId'));
    end
    if ~ismatrix(P)
        error(message('MATLAB:boundary:InvalidPointsMatrix'));
    end
    if size(P, 2) < 2 || size(P, 2) > 3
        error(message('MATLAB:boundary:Non2D3DInputErrId'));
    end
end

function sanityCheckShrink(S)
    if ~isscalar(S) || ~isnumeric(S) || ~isfinite(S) || ~isreal(S) || issparse(S) || S < 0 || S > 1
        error(message('MATLAB:boundary:InvalidShrinkFactor'));
    end
end
