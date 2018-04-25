%images.geotrans.PiecewiseLinearTransformation2D 2-D Piecewise Linear Geometric Transformation
%
%   An images.geotrans.PiecewiseLinearTransformation2D object encapsulates a 2-D piecewise linear geometric transformation. 
%
%   images.geotrans.PiecewiseLinearTransformation2D properties:
%      Dimensionality - Dimensionality of geometric transformation
%
%   images.geotrans.PiecewiseLinearTransformation2D methods:
%      PiecewiseLinearTransformation2D - Construct images.geotrans.PiecewiseLinearTransformation2D object
%      outputLimits - Find output spatial limits given input spatial limits
%      transformPointsInverse - Apply inverse 2-D geometric transformation to points
%
%   Example 1
%   ---------
%   % Fit a piecewise linear transformation to a set of fixed and moving
%   % control points that are actually related by a single global affine2d
%   % transformation across the domain.
%   theta = 10;
%   tformAffine = affine2d([cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1]);
%
%   % Arbitrarily choose 6 pairs of control points.
%   fixedPoints = [10 20; 10 5; 2 3; 0 5; -5 3; -10 -20];
%
%   % Apply forward geometric transformation to map fixed points to obtain
%   % effect of fixed and moving points that are related by some geometric
%   % transformation.
%   movingPoints = transformPointsForward(tformAffine,fixedPoints);
%
%   % Estimate piecewise linear transformation that maps movingPoints to fixedPoints.
%   tformPiecewiseLinear = images.geotrans.PiecewiseLinearTransformation2D(movingPoints,fixedPoints);
%
%   % Verify the fit of our PiecewiseLinearTransformation2D object at the control
%   % points.
%   movingPointsComputed = transformPointsInverse(tformPiecewiseLinear,fixedPoints);
%
%   errorInFit = hypot(movingPointsComputed(:,1)-movingPoints(:,1),...
%                      movingPointsComputed(:,2)-movingPoints(:,2))
%
%   See also AFFINE2D, IMWARP

% Copyright 2012-2017 The MathWorks, Inc.

classdef PiecewiseLinearTransformation2D < images.geotrans.internal.GeometricTransformation
    
    
    properties (Access = private)
        
        normTransformXY
        normTransformUV
        
    end
    
    methods
             
        function self = PiecewiseLinearTransformation2D(uv,xy)
            %PiecewiseLinearTransformation2D Construct images.geotrans.PiecewiseLinearTransformation2D object
            %
            %   tform = images.geotrans.PiecewiseLinearTransformation2D(movingPoints,fixedPoints)
            %   constructs an images.geotrans.PiecewiseLinearTransformation2D object
            %   given Mx2 matrices movingPoints, and fixedPoints which
            %   define matched control points in the moving and fixed
            %   images, respectively.
            
            % Define required property from base class
            self.Dimensionality = 2;
            
            images.geotrans.internal.validateControlPoints(uv,xy);
            
            self.UVVertices = uv;
            self.XYVertices = xy;
            
            [uv,normMatrixUV] = images.geotrans.internal.normalizeControlPoints(uv);
            [xy,normMatrixXY] = images.geotrans.internal.normalizeControlPoints(xy);
            self.normTransformUV = affine2d(normMatrixUV);
            self.normTransformXY = affine2d(normMatrixXY);
            
            % MEX module currently requires that computation is done in
            % double
            self.NumericPrecision = 'double';
            if ~isa(uv,'double') || ~isa(xy,'double')
                uv = double(uv);
                xy = double(xy);
                self.NumericPrecision = 'single';
            end  
               
            x = xy(:,1);
            y = xy(:,2);
            
            tri = delaunay(x,y);
            
            ntri = size(tri,1);
            
            % Require 4 points (2 triangles).
            minRequiredPoints = 4;
            
            if (ntri<2)
                error(message('images:geotrans:requiredNonCollinearPoints', minRequiredPoints, 'piecewise linear'));
            end
            
            % Find all inside-out triangles
            bad_triangles =  FindInsideOut(xy,uv,tri);
           
            if ~isempty(bad_triangles)
                [xy,uv,tri,ntri] = eliminateFoldOverTriangles(self,bad_triangles,xy,uv,tri);
            end
            
            % calculate reverse mapping for each triangle
            T = zeros(3,2,ntri);
            for itri = 1:ntri
                
                X = [ xy( tri(itri,:), : ) ones(3,1)];
                U =   uv( tri(itri,:), : );
                if (rank(X) >= 3)
                    T(:,:,itri) = X\U;
                else
                    error(message('images:geotrans:requiredNonCollinearPoints', minRequiredPoints, 'piecewise linear'));
                end
                
            end
            
            % Create TriangleGraph which is a sparse connectivity matrix
            nxy = size(xy,1);
            S = sparse( repmat((1:ntri)',1,3), tri, 1, ntri, nxy);
            
            % Create OnHull to be 1 for ControlPoints on convex hull, 0 for
            % interior points.
            hull_indices = convhull(xy(:,1),xy(:,2));
            
            self.State = struct('Triangles',[],...
                'ControlPoints',[],...
                'OnHull',[],...
                'ConvexHullVertices',[],...
                'TriangleGraph',[],...
                'PiecewiseLinearTData',[]);
            
            self.State.OnHull = zeros(size(xy(:,1)));
            self.State.OnHull(hull_indices) = 1;
            
            self.State.Triangles = tri;
            self.State.ControlPoints = xy;
            self.State.ConvexHullVertices = hull_indices;
            self.State.TriangleGraph = S;
            self.State.PiecewiseLinearTData = T;
            
        end
        
        function varargout = transformPointsInverse(self,varargin)
            %transformPointsInverse Apply inverse geometric transformation
            %
            %   [u,v] = transformPointsInverse(tform,x,y)
            %   applies the inverse transformation of tform to the input 2-D
            %   point arrays x,y and outputs the point arrays u,v. The
            %   input point arrays x and y must be of the same size.
            %
            %   U = transformPointsInverse(tform,X)
            %   applies the inverse transformation of tform to the input
            %   Nx2 point matrix X and outputs the Nx2 point matrix U.
            %   transformPointsFoward maps the point X(k,:) to the point
            %   U(k,:).
            
            if numel(varargin) > 1
                x = varargin{1};
                y = varargin{2};
                
                validateattributes(x,{'single','double'},{'real','nonsparse'},...
                    'transformPointsInverse','X');
                
                validateattributes(y,{'single','double'},{'real','nonsparse'},...
                    'transformPointsInverse','Y');
                
                if ~isequal(size(x),size(y))
                    error(message('images:geotrans:transformPointsSizeMismatch','transformPointsInverse','X','Y'));
                end
                
                inputPointDims = size(x);
                
                x = reshape(x,numel(x),1);
                y = reshape(y,numel(y),1);
                X = [x,y];
                X = self.normTransformXY.transformPointsInverse(X); % normalize
                U = images.geotrans.internal.inv_piecewiselinear(self.State,double(X));
                U = self.normTransformUV.transformPointsForward(U); % denormalize
                
                % If class was constructed from single control points or if
                % points passed to transformPointsInverse are single,
                % return single to emulate MATLAB Math casting rules.
                if isa(X,'single') || strcmp(self.NumericPrecision,'single')
                    U = single(U);
                end
                varargout{1} = reshape(U(:,1),inputPointDims);
                varargout{2} = reshape(U(:,2), inputPointDims);
                
            else
                X = varargin{1};
                
                validateattributes(X,{'single','double'},{'real','nonsparse','2d'},...
                    'transformPointsInverse','X');
                
                if ~isequal(size(X,2),2)
                    error(message('images:geotrans:transformPointsPackedMatrixInvalidSize',...
                        'transformPointsInverse','X'));
                end
                
                X = self.normTransformXY.transformPointsInverse(X); % normalize
                U = images.geotrans.internal.inv_piecewiselinear(self.State,double(X));
                U = self.normTransformUV.transformPointsForward(U); % denormalize
                
                % If class was constructed from single control points or if
                % points passed to transformPointsInverse are single,
                % return single to emulate MATLAB Math casting rules.
                if isa(X,'single') || strcmp(self.NumericPrecision,'single')
                    U = single(U);
                end
                varargout{1} = U;
            end
            
            
        end
        
    end
    
    properties (Access = 'private')
        
        State
        BadXYVertices
        BadUVVertices
        XYVertices
        UVVertices
        NumericPrecision
        
    end
    
    methods (Access = 'private')
        
        function [xy,uv,tri,ntri] = eliminateFoldOverTriangles(self,bad_triangles,xy,uv,tri)
            
            x = xy(:,1);
            y = xy(:,2);
            
            % find bad_vertices, eliminate bad_vertices
            num_bad_triangles = length(bad_triangles);
            bad_vertices = zeros(num_bad_triangles,1);
            for i = 1:num_bad_triangles
                bad_vertices(i) = FindBadVertex(x,y,tri(bad_triangles(i),:));
            end
            bad_vertices = unique(bad_vertices);
            num_bad_vertices = length(bad_vertices);
            
            % Cache bad vertices that were eliminated
            self.BadXYVertices = xy(bad_vertices,:);
            self.BadUVVertices = uv(bad_vertices,:);
            
            xy(bad_vertices,:) = []; % eliminate bad ones
            uv(bad_vertices,:) = [];
            nvert = size(xy,1);
            
            % Cache good vertices
            self.XYVertices = xy;
            self.UVVertices = uv;
            
            minRequiredPoints = 4;
            if (nvert < minRequiredPoints)
                error(message('images:geotrans:deletedPointsNowInsufficientControlPoints', num_bad_vertices, nvert, minRequiredPoints, 'piecewise linear'))
            end
            x = xy(:,1);
            y = xy(:,2);
            tri = delaunay(x,y);
            ntri = size(tri,1);
            
            % Error if we cannot produce a valid piecewise linear correspondence
            % after the second triangulation.
            more_bad_triangles = FindInsideOut(xy,uv,tri);
            if ~isempty(more_bad_triangles)
                error(message('images:geotrans:foldoverTrianglesRemain', num_bad_vertices))
            end
            
            % Warn to report about triangles and how many points were eliminated
            warning(message('images:geotrans:foldoverTriangles', sprintf( '%d ', bad_triangles ), sprintf( '%d ', bad_vertices )))
            
        end
        
    end
    
    % saveobj and loadobj are implemented to ensure compatibility across
    % releases even if architecture of geometric transformation classes
    % changes.
    methods (Hidden)
        
        function S = saveobj(self)
            
            S = struct('uvPoints',self.UVVertices,'xyPoints',self.XYVertices);
            
        end
        
    end
    
    methods (Static, Hidden)
        
        function self = loadobj(S)
            
            self = images.geotrans.PiecewiseLinearTransformation2D(S.uvPoints,S.xyPoints);
            
        end
        
    end
end

function index = FindInsideOut(xy,uv,tri)

% look for inside-out triangles using line integrals
x = xy(:,1);
y = xy(:,2);
u = uv(:,1);
v = uv(:,2);

p = size(tri,1);

xx = reshape(x(tri),p,3)';
yy = reshape(y(tri),p,3)';
xysum = sum( (xx([2 3 1],:) - xx).* (yy([2 3 1],:) + yy), 1 );

uu = reshape(u(tri),p,3)';
vv = reshape(v(tri),p,3)';
uvsum = sum( (uu([2 3 1],:) - uu).* (vv([2 3 1],:) + vv), 1 );

index = find(xysum.*uvsum<0);

end

function vertex = FindBadVertex(x,y,vertices)

% Get middle vertex of triangle where "middle" means the largest angle,
% which will have the smallest cosine.

vx = x(vertices)';
vy = y(vertices)';
abc = [ vx - vx([3 1 2]); vy - vy([3 1 2]) ];
a = abc(:,1);
b = abc(:,2);
c = abc(:,3);

% find cosine of angle between 2 vectors
vcos(1) = get_cos(-a, b);
vcos(2) = get_cos(-b, c);
vcos(3) = get_cos( a,-c);

[~, index] = min(vcos);
vertex = vertices(index);

end

%-------------------------------
% Function get_cos
%
function vcos = get_cos(a,b)

mag_a = hypot(a(1),a(2));
mag_b = hypot(b(1),b(2));
vcos = dot(a,b) / (mag_a*mag_b);

end


