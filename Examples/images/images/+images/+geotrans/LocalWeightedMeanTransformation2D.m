%images.geotrans.LocalWeightedMeanTransformation2D 2-D Local Weighted Mean Geometric Transformation
%
%   An images.geotrans.LocalWeightedMeanTransformation2D object encapsulates a 2-D local weighted mean geometric transformation.
%
%   images.geotrans.LocalWeightedMeanTransformation2D properties:
%      Dimensionality - Dimensionality of geometric transformation
%
%   images.geotrans.LocalWeightedMeanTransformation2D methods:
%      LocalWeightedMeanTransformation2D - Construct images.geotrans.LocalWeightedMeanTransformation2D object
%      outputLimits - Find output spatial limits given input spatial limits
%      transformPointsInverse - Apply inverse 2-D geometric transformation to points
%
%   Example 1
%   ---------
%   % Fit a local weighted mean transformation to a set of fixed and moving
%   % control points that are actually related by a global second degree
%   % polynomial transformation across the entire plane.
%   x = [10, 12, 17, 14, 7, 10];
%   y = [8, 2, 6, 10, 20, 4];
%
%   a = [1 2 3 4 5 6];
%   b = [2.3 3 4 5 6 7.5];
%
%   u = a(1) + a(2).*x + a(3).*y + a(4) .*x.*y + a(5).*x.^2 + a(6).*y.^2;
%   v = b(1) + b(2).*x + b(3).*y + b(4) .*x.*y + b(5).*x.^2 + b(6).*y.^2;
%
%   movingPoints = [u',v'];
%   fixedPoints = [x',y'];
%
%   % Fit local weighted mean transformation to points.
%   tformLocalWeightedMean = images.geotrans.LocalWeightedMeanTransformation2D(movingPoints,fixedPoints,6);
%
%   % Verify the fit of our LocalWeightedMeanTransformation2D object at the control
%   % points.
%   movingPointsComputed = transformPointsInverse(tformLocalWeightedMean,fixedPoints);
%
%   errorInFit = hypot(movingPointsComputed(:,1)-movingPoints(:,1),...
%                      movingPointsComputed(:,2)-movingPoints(:,2))
%
%   See also AFFINE2D, IMWARP

% Copyright 2012-2016 The MathWorks, Inc.

classdef LocalWeightedMeanTransformation2D < images.geotrans.internal.GeometricTransformation
    
    
    properties (Access = private)
        
        State
        uvPoints
        xyPoints
        Degree
        N
        NumericPrecision
        
        normTransformUV
        normTransformXY
                
    end
    
    methods
        
        function self = LocalWeightedMeanTransformation2D(uv,xy,N)
            %LocalWeightedMeanTransformation2D Construct images.geotrans.LocalWeightedMeanTransformation2D object
            %
            %   tform = images.geotrans.LocalWeightedMeanTransformation2D(movingPoints,fixedPoints,N)
            %   constructs an images.geotrans.LocalWeightedMeanTransformation2D object
            %   given Mx2 matrices movingPoints, and fixedPoints which
            %   define matched control points in the moving and fixed
            %   images, respectively.  The local weighted mean
            %   transformation creates a mapping, by inferring a polynomial
            %   at each control point using neighboring control points. The
            %   mapping at any location depends on a weighted average of
            %   these polynomials. The N closest points are used to infer a
            %   second degree polynomial transformation for each control
            %   point pair. N can be as small as 6, but making N small
            %   risks generating ill-conditioned polynomials.
            
            self.Dimensionality = 2;
            
            self.Degree = 2;
                        
            M = size(xy,1);
            
            K = (self.Degree+1)*(self.Degree+2)/2;
            
            validateControlPoints(uv,xy,N);
            
            self.uvPoints = uv;
            self.xyPoints = xy;
            
            [uv,normMatrixUV] = images.geotrans.internal.normalizeControlPoints(uv);
            [xy,normMatrixXY] = images.geotrans.internal.normalizeControlPoints(xy);
            self.normTransformUV = affine2d(normMatrixUV);
            self.normTransformXY = affine2d(normMatrixXY);
            
            self.NumericPrecision = 'double';
            if ~isa(uv,'double') || ~isa(xy,'double')
                % Underlying tformlocalmex module requires that properties
                % are computed in double.
                uv = double(uv);
                xy = double(xy);
                self.NumericPrecision = 'single';
            end
            

            self.N = N;
            
            x = xy(:,1);
            y = xy(:,2);
            u = uv(:,1);
            v = uv(:,2);
            
            T = zeros(K,2,M);
            radii = zeros(M,1);
            for icp = 1:M
                
                % find N closest points
                distcp = sqrt( (x-x(icp)).^2 + (y-y(icp)).^2 );
                [dist_sorted,indx] = sort(distcp);
                radii(icp) = dist_sorted(N);
                neighbors = indx(1:N);
                neighbors = sort(neighbors);
                xcp = x(neighbors);
                ycp = y(neighbors);
                ucp = u(neighbors);
                vcp = v(neighbors);
                
                % set up matrix equation for second degree polynomial.
                X = [ones(N,1),  xcp,  ycp,  xcp.*ycp,  xcp.^2,  ycp.^2];
                
                if rank(X)>=K
                    % u = X*A, v = X*B, solve for A and B:
                    A = X\ucp;
                    B = X\vcp;
                    T(:,:,icp) = [A B];
                else
                    error(message('images:geotrans:requiredNonCollinearPoints', K, 'polynomial'))
                end
                
            end
            
            % State is a struct that we use to package up data to pass to
            % the MEX module that computes the inverse transformation.
            self.State = struct('LWMTData',[],'ControlPoints',[],'RadiiOfInfluence',[]);
            self.State.LWMTData = T;
            self.State.ControlPoints = xy;
            self.State.RadiiOfInfluence = radii;
            
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
                U = images.geotrans.internal.inv_lwm(self.State,double(X));
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
                U = images.geotrans.internal.inv_lwm(self.State,double(X));
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
    
    % saveobj and loadobj are implemented to ensure compatibility across
    % releases even if architecture of geometric transformation classes
    % changes.
    methods (Hidden)
        
        function S = saveobj(self)
            
            S = struct('uvPoints',self.uvPoints,'xyPoints',self.xyPoints,'N',self.N);
            
        end
        
    end
    
    methods (Static, Hidden)
        
        function self = loadobj(S)
            
            self = images.geotrans.LocalWeightedMeanTransformation2D(S.uvPoints,S.xyPoints,S.N);
            
        end
        
    end
    
end

function validateControlPoints(xy,uv,N)

images.geotrans.internal.validateControlPoints(uv,xy);

validateattributes(N,{'numeric'},{'real','nonsparse','scalar'},...
    'LocalWeightedMeanTransformation2D','N');

if N < 6
    error(message('images:geotrans:LWMSecondDegreePolynomialRequires6Points')); 
end

if N > size(xy,1)
    error(message('images:geotrans:LWMNGreaterThanNumPoints'));
end

end
