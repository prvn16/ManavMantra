%affine2d 2-D Affine Geometric Transformation
%
%   An affine2d object encapsulates a 2-D affine geometric transformation. 
%
%   affine2d properties:
%      T - 3x3 matrix representing forward affine transformation
%      Dimensionality - Dimensionality of geometric transformation
%
%   affine2d methods:
%      affine2d - Construct affine2d object
%      invert - Invert geometric transformation
%      isTranslation - Determine if transformation is pure translation special case
%      isRigid - Determine if transformation is rigid transformation special case
%      isSimilarity - Determine if transformation is similarity transformation special case
%      outputLimits - Find output spatial limits given input spatial limits
%      transformPointsForward - Apply forward 2-D geometric transformation to points
%      transformPointsInverse - Apply inverse 2-D geometric transformation to points
%
%   Example 1
%   ---------
%   % Construct an affine2d object that defines a rotation of 10 degrees
%   % counter-clockwise.
%   theta = 10;
%   tform = affine2d([cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1]);
%
%   % Apply forward geometric transformation to an input (U,V) point (5,10)
%   [X,Y] = transformPointsForward(tform,5,10)
%
%   % Apply inverse geometric transformation to output (X,Y) point from
%   % previous step. We recover the point we started with from
%   % the inverse transformation.
%   [U,V] = transformPointsInverse(tform,X,Y)
%
%   Example 2
%   ---------
%   % Apply 10 degree counter-clockwise rotation to an image using the function imwarp
%   A = imread('pout.tif');
%   theta = 10;
%   tform = affine2d([cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1]);
%   outputImage = imwarp(A,tform);
%   figure, imshow(outputImage);

%   See also AFFINE3D, PROJECTIVE2D, IMWARP

% Copyright 2012-2014 The MathWorks, Inc.

%#ok<*EMCA>

classdef affine2d < images.geotrans.internal.GeometricTransformation %#codegen
        
    properties
       
        %T - Forward transformation matrix
        %
        %    T is a 3x3 floating point matrix that defines the 2-D forward
        %    transformation. The matrix T uses the convention:
        %
        %    [x y 1] = [u v 1] * T
        %
        %    Where T has the form:
        %
        %    [a b 0;...
        %     c d 0;...
        %     e f 1];
        T
                  
    end
    
    
    properties (Dependent = true, Access = private, Hidden = true)
        
        %Tinv - Inverse transformation matrix
        %
        %    Tinv is a 3x3 floating point matrix that defines the 2-D
        %    inverse transformation. The matrix uses the convention:
        %
        %    [u v 1] =  [x y 1] * Tinv;
        %
        %    Where Tinv has the form:
        %
        %    [a b 0;
        %     c d 0;
        %     e f 1];
        Tinv
        
    end
    
    
    methods
        
        function self = affine2d(A)
            %affine2d Construct affine2d object
            %
            %   tform = affine2d() constructs an affine2d object with default
            %   property settings that correspond to the identity
            %   transformation.
            %
            %   tform = affine2d(A) constructs an affine2d object given an
            %   input 3x3 matrix A that specifies a valid 3x3 affine
            %   transformation matrix. A must be of the form:
            %
            %    A = [a b 0;
            %         c d 0;
            %         e f 1];
            
            coder.inline('always');
            
            if nargin == 0
                self.T = eye(3);
            else
                self.T = A; 
            end
            
            self.Dimensionality = 2;
                            
        end
        
        
        function varargout = transformPointsForward(self,varargin)
            %transformPointsForward Apply forward geometric transformation
            %
            %   [x,y] = transformPointsForward(tform,u,v)
            %   applies the forward transformation of tform to the input 2-D
            %   point arrays u,v and outputs the point arrays x,y. The
            %   input point arrays u and v must be of the same size.
            %
            %   X = transformPointsForward(tform,U)
            %   applies the forward transformation of tform to the input
            %   Nx2 point matrix U and outputs the Nx2 point matrix X.
            %   transformPointsFoward maps the point U(k,:) to the point
            %   X(k,:).
                      
            coder.inline('always');
            coder.internal.prefer_const(self,varargin);
            
            packedPointsSpecified = (nargin==2);
            if packedPointsSpecified
                
                U = varargin{1};
                validateattributes(U,{'single','double'},{'2d','nonsparse'},'images:affine2d:transformPointsForward','U');
                
                coder.internal.errorIf(~isequal(size(U,2),2),...
                    'images:geotrans:transformPointsPackedMatrixInvalidSize',...
                    'transformPointsForward','U');
                
                % Append an all ones column to put U in homogeneous
                % coordinates for matrix multiply.
                U = padarray(U,[0 1],1,'post');
                
                X = U*self.T;
                varargout{1} = X(:,1:2);
                
            else
                
                narginchk(3,3);
                u = varargin{1};
                v = varargin{2};
                
                coder.internal.errorIf(~isequal(size(u),size(v)),...
                    'images:geotrans:transformPointsSizeMismatch',...
                    'transformPointsForward','U','V');
                
                validateattributes(u,{'double','single'},{'nonsparse'},'images:affine2d:transformPointsForward','U');
                validateattributes(v,{'double','single'},{'nonsparse'},'images:affine2d:transformPointsForward','V');
                
                M = self.T;
                
                if(coder.target('MATLAB'))
                    M = double(M);
                    varargout{1} = imlincomb(M(1,1),u, M(2,1),v,   M(3,1), class(self.T));
                    varargout{2} = imlincomb(M(1,2),u, M(2,2),v,   M(3,2), class(self.T));
                else                    
                    varargout{1} = M(1,1).*u + M(2,1).*v + M(3,1);
                    varargout{2} = M(1,2).*u + M(2,2).*v + M(3,2);                    
                end           
            end
                        
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
                      
            coder.inline('always');
            coder.internal.prefer_const(self,varargin);
            
            packedPointsSpecified = (nargin==2);
            if packedPointsSpecified
                
                X = varargin{1};
                validateattributes(X,{'single','double'},{'2d','nonsparse'},'images:affine2d:transformPointsInverse','X');
                
                coder.internal.errorIf(~isequal(size(X,2),2),...
                    'images:geotrans:transformPointsPackedMatrixInvalidSize',...
                    'transformPointsInverse','X');
                
                % Append an all ones column to put U in homogeneous
                % coordinates for matrix multiply.
                X = padarray(X,[0 1],1,'post');
                
                U = X*self.Tinv;
                varargout{1} = U(:,1:2);
                
            else
                
                narginchk(3,3);
                x = varargin{1};
                y = varargin{2};
                
                coder.internal.errorIf(~isequal(size(x),size(y)),...
                    'images:geotrans:transformPointsSizeMismatch',...
                    'transformPointsInverse','X','Y');
                
                validateattributes(x,{'double','single'},{'nonsparse'},'images:affine2d:transformPointsInverse','X');
                validateattributes(y,{'double','single'},{'nonsparse'},'images:affine2d:transformPointsInverse','Y');
                
                M = self.Tinv;
                
                if(coder.target('MATLAB'))
                    M = double(M);
                    varargout{1} = imlincomb(M(1,1),x, M(2,1),y,   M(3,1), class(self.Tinv));
                    varargout{2} = imlincomb(M(1,2),x, M(2,2),y,   M(3,2), class(self.Tinv));
                else                                 
                    varargout{1} = M(1,1).*x + M(2,1).*y + M(3,1);
                    varargout{2} = M(1,2).*x + M(2,2).*y + M(3,2);
                end
                
                
            end
            
        end
        
        function [xLimitsOut,yLimitsOut] = outputLimits(self,xLimitsIn,yLimitsIn)
            %outputLimits Find output limits of geometric transformation
            %
            %   [xLimitsOut,yLimitsOut] = outputLimits(tform,xLimitsIn,yLimitsIn) estimates the
            %   output spatial limits corresponding to a given geometric
            %   transformation and a set of input spatial limits.
            
            coder.inline('always');
            coder.internal.prefer_const(self,xLimitsIn,yLimitsIn);
            
            validateattributes(xLimitsIn,{'double'},{'size',[1 2],'finite','nonnan','nonempty'},'images.geotrans.internal.GeometricTransformation.outputLimits','xLimitsIn');
            validateattributes(yLimitsIn,{'double'},{'size',[1 2],'finite','nonnan','nonempty'},'images.geotrans.internal.GeometricTransformation.outputLimits','yLimitsIn');
            
            u = [xLimitsIn(1), mean(xLimitsIn), xLimitsIn(2)];
            v = [yLimitsIn(1), mean(yLimitsIn), yLimitsIn(2)];
            
            % Form grid of boundary points and internal points used by
            % findbounds algorithm.
            [U,V] = meshgrid(u,v);
            
            % Transform gridded points forward
            [X,Y] = transformPointsForward(self,U,V);
            
            % XLimitsOut/YLimitsOut are formed from min and max of transformed points.
            xLimitsOut = [min(X(:)), max(X(:))];
            yLimitsOut = [min(Y(:)), max(Y(:))];
        end
        
        function invtform = invert(self)
            %invert Invert geometric transformation
            %
            %   invtform = invert(tform) inverts the geometric
            %   transformation tform and returns the inverse geometric
            %   transform.
            
            coder.inline('always');
            coder.internal.prefer_const(self);
            
            self.T = self.Tinv;
            invtform = self;
            
        end
        
        function TF = isTranslation(self)
            %isTranslation Determine if transformation is pure translation
            %
            %   TF = isTranslation(tform) determines whether or not affine
            %   transformation is a pure translation transformation. TF is
            %   a scalar boolean that is true when tform defines only
            %   translation.
            
            coder.inline('always');
            coder.internal.prefer_const(self);
            
            TF = isequal(self.T(1:self.Dimensionality,1:self.Dimensionality),...
                         eye(self.Dimensionality));

        end

        function TF = isRigid(self)
            %isRigid Determine if transformation is rigid transformation
            %
            %   TF = isRigid(tform) determines whether or not affine
            %   transformation is a rigid transformation. TF is a scalar
            %   boolean that is true when tform is a rigid transformation. The
            %   tform is a rigid transformation when tform.T defines only
            %   rotation and translation.

            coder.inline('always');
            coder.internal.prefer_const(self);
            
            TF = isSimilarity(self) && abs(det(self.T)-1) < 10*eps(class(self.T));

        end

        function TF = isSimilarity(self)
            %isSimilarity Determine if transformation is similarity transformation
            %
            %   TF = isSimilarity(tform) determines whether or not affine
            %   transformation is a similarity transformation. TF is a scalar
            %   boolean that is true when tform is a similarity transformation. The
            %   tform is a similarity transformation when tform defines only
            %   homogeneous scale, rotation, and translation.

            coder.inline('always');
            coder.internal.prefer_const(self);
            
            % Check for expected symmetry in diagonal and off diagonal
            % elements.
            singularValues = svd(self.T(1:self.Dimensionality,1:self.Dimensionality));

            % For homogeneous scale, expect all singular values to be equal
            % to each other within roughly eps of the largest singular value present.
            TF = max(singularValues)-min(singularValues) < 10*eps(max(singularValues(:)));

        end
        
                                                                      
    end
    
    methods
        % Set/Get methods
        function self = set.T(self,T)
            
            coder.inline('always');
            coder.internal.prefer_const(T);
            
            % This is to support internal CVST requirement of allowing 3x2
            % specification of affine matrix. 
            if isnumeric(T) && isequal(size(T),[3 2])
                t = [T,[0 0 1]'];
            else
                t = T;
            end
            
            % validate size and that T is finite
            validateattributes(t,{'single','double'},{'size',[3 3],'finite','nonsparse'},...
                'affine2d.set.T',...
                'T');
            
            % Also require that T is non-singular.
            coder.internal.errorIf(isequal(det(t),0),...
                'images:geotrans:singularTransformationMatrix');
         
            % Check last column of T
            coder.internal.errorIf(~isequal(t(:,3),[0 0 1]'),...
                'images:geotrans:invalidAffineMatrix');
            
            self.T = t;
            
        end
        
        function Tinv = get.Tinv(self)
           
            coder.inline('always');
            coder.internal.prefer_const(self);
            
            tinv = inv(self.T);
            tinv(:,end) = [0;0;1];
            Tinv = tinv;
            
        end
        
    end
    
    % saveobj and loadobj are implemented to ensure compatibility across
    % releases even if architecture of geometric transformation classes
    % changes.
    methods (Hidden)
       
        function S = saveobj(self)
            
            S = struct('TransformationMatrix',self.T);
            
        end
        
    end
    
    methods (Static, Hidden)
       
        function self = loadobj(S)
           
            self = affine2d(S.TransformationMatrix);
            
        end
        
    end
    
    methods (Static,Hidden)
        
        function TF = isvalid(T)
            %isvalid Determine if transformation matrix is valid
            %
            %   TF = affine2d.isvalid(T) determines whether the
            %   transformation matrix T is a valid parameterization of a
            %   2-D affine transformation. TF is true when T is a valid
            %   transformation matrix.
            
            coder.inline('always');
            coder.internal.prefer_const(T);
            
            % This is to support internal CVST requirement of allowing 3x2
            % specification of affine matrix.
            if isnumeric(T) && isequal(size(T),[3 2])
                t = [T,[0 0 1]'];
            else
                t = T;
            end
            
            isSupportedClass = isa(t,'single') || isa(t,'double');
            
            TF = isSupportedClass && isequal(size(t),[3 3]) && all(isfinite(t(:))) && ~issparse(t) &&...
                 ~isequal(det(t),0) && isequal(t(:,3),[0 0 1]');
                      
        end
            
        
    end
        
end
