%images.geotrans.PolynomialTransformation2D 2-D Polynomial Geometric Transformation
%
%   An images.geotrans.PolynomialTransformation2D object encapsulates a 2-D polynomial geometric transformation. 
%
%   images.geotrans.PolynomialTransformation2D properties:
%      A - Polynomial coefficients used to determine U in inverse transformation.
%      B - Polynomial coefficients used to determine V in inverse transformation.
%      Degree - Degree of polynomial
%      Dimensionality - Dimensionality of geometric transformation
%
%   images.geotrans.PolynomialTransformation2D methods:
%      PolynomialTransformation2D - Construct images.geotrans.PolynomialTransformation2D object
%      outputLimits - Find output spatial limits given input spatial limits
%      transformPointsInverse - Apply inverse 2-D geometric transformation to points
%
%   Example 1
%   ---------
%   % Fit a second degree polynomial transformation to a set of fixed and
%   % moving control points that are actually related by an affine2d
%   % transformation.
%   theta = 10;
%   tformAffine = affine2d([cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1]);
%
%   % Arbitrarily choose 6 pairs of control points. A second degree
%   % polynomial requires 6 pairs of control points.
%   fixedPoints = [10 20; 10 5; 2 3; 0 5; -5 3; -10 -20];
%
%   % Apply forward geometric transformation to map fixed points to obtain
%   % effect of fixed and moving points that are related by some geometric
%   % transformation.
%   movingPoints = transformPointsForward(tformAffine,fixedPoints);
%
%   % Estimate second degree PolynomialTransformation2D transformation that
%   % fits fixedPoints and movingPoints.
%   tformPolynomial = images.geotrans.PolynomialTransformation2D(movingPoints,fixedPoints,2);
%
%   % Verify the fit of our PolynomialTransformation2D transformation at the control
%   % points.
%   movingPointsEstimated = transformPointsInverse(tformPolynomial,fixedPoints);
%   errorInFit = hypot(movingPointsEstimated(:,1)-movingPoints(:,1),...
%                      movingPointsEstimated(:,2)-movingPoints(:,2))
%
%   See also AFFINE2D, IMWARP

% Copyright 2012-2016 The MathWorks, Inc.

classdef PolynomialTransformation2D < images.geotrans.internal.GeometricTransformation
    
    properties (SetAccess = private)
        
        %Degree - Degree of Polynomial
        %
        %    Degree is a scalar that defines the degree of the polynomial
        %    transformation. Valid values of Degree are 2,3, and 4.
        Degree
        
        %A - Polynomial coefficients used to determine U in inverse transformation.
        %
        %    A is a double vector of length N that defines the polynomial
        %    coefficients used to determine U in the inverse
        %    transformation. For polynomials of degree 2, 3, and 4, N is 6,
        %    10, and 15, respectively. The polynomial coefficient vector A
        %    is ordered as follows:
        %    
        %    U = A(1) + A(2).*X + A(3).*Y + A(4).*X.*Y + A(5).*X.^2 + A(6).*Y.^2 +...
        A
        
        %B - Polynomial coefficients used to determine V in inverse transformation.
        %
        %    B is a double vector of length N that defines the polynomial
        %    coefficients used to determine V in the inverse
        %    transformation. For polynomials of degree 2, 3, and 4, N is 6,
        %    10, and 15, respectively. The polynomial coefficient vector B
        %    is ordered as follows:
        %
        %    V = B(1) + B(2).*X + B(3).*Y + B(4).*X.*Y + B(5).*X.^2 + B(6).*Y.^2 +...
        B
        
    end
    
    properties (Access = private)
       
        normTransformXY
        normTransformUV
        
    end
        
    methods
        
        function self = PolynomialTransformation2D(varargin)
            %PolynomialTransformation2D Construct images.geotrans.PolynomialTransformation2D object
            %
            %   tform = images.geotrans.PolynomialTransformation2D(movingPoints,fixedPoints,degree)
            %   constructs an images.geotrans.PolynomialTransformation2D object
            %   given Mx2 matrices movingPoints, and fixedPoints which
            %   define matched control points in the moving and fixed
            %   images, respectively. Degree is a scalar with value 2,3, or
            %   4 that specifies the degree of the polynomial that is fit
            %   to the control points.
            %
            %   tform = images.geotrans.PolynomialTransformation2D(A,B)
            %   constructs an images.geotrans.PolynomialTransformation2D object
            %   given polynomial coefficient vectors A and B. A is a vector
            %   of polynomial coefficients of length N that is used to
            %   determine U in the inverse transformation. B is a vector of
            %   polynomial coefficients of length N that is used to
            %   determine V in the inverse transformation.  For polynomials of 
            %   degree 2, 3, and 4, N is 6, 10, and 15, respectively.
                        
            narginchk(2, 3)
            
            self.normTransformUV = affine2d(eye(3));
            self.normTransformXY = affine2d(eye(3));
            
            % Inherited from base class.
            self.Dimensionality = 2;
            
            if (nargin == 2)
                % PolynomialTransformation2D(A,B)
                
                self.A = varargin{1};
                self.B = varargin{2};
                
                validatePolynomialCoefficients(self);
                
                % We have successfully validated A and B. Set Degree based on
                % length of A and B.
                mapCoefficientLengthToDegree = containers.Map([6 10 15], [2 3 4]);
                self.Degree = mapCoefficientLengthToDegree(length(self.A));
                
            end
            
            if (nargin == 3)
                % PolynomialTransformation2D(movingPoints,fixedPoints,degree)
                
                UV = varargin{1};
                XY = varargin{2};
                degree = varargin{3};
                
                self.Degree = degree;
                
                images.geotrans.internal.validateControlPoints(XY,UV);
                
                [UV,normMatrixUV] = images.geotrans.internal.normalizeControlPoints(UV);
                [XY,normMatrixXY] = images.geotrans.internal.normalizeControlPoints(XY);
                self.normTransformUV = affine2d(normMatrixUV);
                self.normTransformXY = affine2d(normMatrixXY);
               
                X = self.getTerms(XY);
                
                K = (degree+1)*(degree+2)/2;
                if rank(X)>=K
                    % u = X*A, v = X*B, solve for A and B:
                    self.A = transpose(X \ UV(:,1));
                    self.B = transpose(X \ UV(:,2));
                else
                    error(message('images:geotrans:requiredNonCollinearPoints', K, 'polynomial'))
                end
                
            end
                        
        end
        
        function varargout = transformPointsInverse(varargin)
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
            
            
            packedPointsSpecified = (nargin == 2);

            if packedPointsSpecified
                self = varargin{1};
                xy  = varargin{2};
                
                validateattributes(xy,{'single','double'},{'2d','nonsparse'},'images:geotrans:PolynomialTransformation2D:transformPointsInverse','X');

                if ~isequal(size(xy,2),2)
                    error(message('images:geotrans:transformPointsPackedMatrixInvalidSize',...
                        'transformPointsInverse','X'));
                end
                
                xy = self.normTransformXY.transformPointsInverse(xy);
                
                X = self.getTerms(xy);
                uv = X * [self.A;self.B]';
                varargout{1} = self.normTransformUV.transformPointsForward(uv);
                
            else
                narginchk(3,3);
                self = varargin{1};
                x = varargin{2};
                y = varargin{3};
                
                validateattributes(x,{'double','single'},{'nonsparse'},'images:geotrans:PolynomialTransformation2D:transformPointsInverse','X');
                validateattributes(y,{'double','single'},{'nonsparse'},'images:geotrans:PolynomialTransformation2D:transformPointsInverse','Y');
                
                if ~isequal(size(x),size(y))
                    error(message('images:geotrans:transformPointsSizeMismatch','transformPointsInverse','X','Y'));
                end
                
                M = size(x,1);
                N = size(x,2);
                x = reshape(x,numel(x),1);
                y = reshape(y,numel(y),1);
                xy = [x,y];
               
                xy = self.normTransformXY.transformPointsInverse(xy); 
                X = self.getTerms(xy);
                uv = X * [self.A;self.B]';
                uv = self.normTransformUV.transformPointsForward(uv);
                
                varargout{1} = reshape(uv(:,1),M,N);
                varargout{2} = reshape(uv(:,2),M,N);
            end
            
        end
        
        function self = set.Degree(self,degreeIn)
           
            validateattributes(degreeIn,{'numeric'},{'scalar','nonsparse'},'PolynomialTransformation2D','Degree');
            
            degreeIn = double(degreeIn);
            
            validDegree = any(degreeIn == [2 3 4]);
            if ~validDegree
                error(message('images:geotrans:polynomialDegree','Degree'));
            end
            
            self.Degree = degreeIn;
                        
        end
        
    end
    
    methods (Access = private)
        
        function X = getTerms(self,xy)
            
            M = size(xy,1);
            x = xy(:,1);
            y = xy(:,2);
            
            switch self.Degree
                case 2
                    X = [ones(M,1),  x,  y,  x.*y,  x.^2,  y.^2];
                    
                case 3
                    X = [ones(M,1),  x,  y,  x.*y,  x.^2,  y.^2, ...
                        (x.^2).*y,  (y.^2).*x,  x.^3,  y.^3];
                    
                case 4
                    X = [ones(M,1),  x,  y,  x.*y,  x.^2,  y.^2, ...
                        (x.^2).*y,  (y.^2).*x,  x.^3,  y.^3, ...
                        (x.^3).*y,  (x.^2).*(y.^2),  x.*(y.^3),  x.^4,  y.^4];
                    
                otherwise
                    assert(false,'Invalid degree passed to PolynomialTransformation2D/getTerms.');
            end
                
        end
        
        function self = validatePolynomialCoefficients(self)
            
            validateattributes(self.A,{'single','double'},{'real','vector','finite'},...
                mfilename,'A',1);
            
            validateattributes(self.B,{'single','double'},{'real','vector','finite'},...
                mfilename,'B',2);
            
            numCoeffs = length(self.A);
            if (length(self.A) ~= length(self.B)) || ~any(numCoeffs == [6 10 15])
                error(message('images:geotrans:polynomialCoefficients'));
            end
                        
        end
        
    end
    
    
    % saveobj and loadobj are implemented to ensure compatibility across
    % releases even if architecture of geometric transformation classes
    % changes.
    methods (Hidden)
        
        function S = saveobj(self)
            
            % Serialize Polynomial2D in terms of A and B polynomial
            % coefficients.
            S = struct('A',self.A,'B',self.B,'normTransformXY',self.normTransformXY,...
                'normTransformUV',self.normTransformUV);
            
        end
        
    end
    
    methods (Static, Hidden)
        
        function self = loadobj(S)
            
            preR2017aVersion = ~isfield(S,'normTransformUV');
            if preR2017aVersion
                self = images.geotrans.PolynomialTransformation2D(S.A,S.B);
            else
                self = images.geotrans.PolynomialTransformation2D(S.A,S.B);
                self.normTransformXY = S.normTransformXY;
                self.normTransformUV = S.normTransformUV;
            end
        end
    end
end