%affine3d 3-D Affine Geometric Transformation
%
%   An affine3d object encapsulates a 3-D affine geometric transformation. 
%
%   affine3d properties:
%      T - 4x4 matrix representing forward affine transformation
%      Dimensionality - Dimensionality of geometric transformation
%
%   affine3d methods:
%      affine3d - Construct affine3d object
%      invert - Invert geometric transformation
%      isTranslation - Determine if transformation is pure translation special case
%      isRigid - Determine if transformation is rigid transformation special case
%      isSimilarity - Determine if transformation is similarity transformation special case
%      outputLimits - Find output spatial limits given input spatial limits
%      transformPointsForward - Apply forward 3-D geometric transformation to points
%      transformPointsInverse - Apply inverse 3-D geometric transformation to points
%
%   Example 1
%   ---------
%   % Construct an affine3d object that defines a different scale factor in
%   % each dimension.
%   Sx = 1.2;
%   Sy = 1.6;
%   Sz = 2.4;
%   tform = affine3d([Sx 0 0 0; 0 Sy 0 0; 0 0 Sz 0; 0 0 0 1]);
%
%   % Apply forward geometric transformation to an input (U,V,W) point (1,1,1)
%   [X,Y,Z] = transformPointsForward(tform,1,1,1)
%
%   % Apply inverse geometric transformation to output (X,Y,Z) point from
%   % previous step. We recover the point we started with from
%   % the inverse transformation.
%   [U,V,W] = transformPointsInverse(tform,X,Y,Z)
%
%   Example 2
%   ---------
%   % Apply scale transformation to an MRI volume using the function imwarp
%   A = load('mri');
%   A = squeeze(A.D);
%   Sx = 1.2;
%   Sy = 1.6;
%   Sz = 2.4;
%   tform = affine3d([Sx 0 0 0; 0 Sy 0 0; 0 0 Sz 0; 0 0 0 1]);
%   outputImage = imwarp(A,tform);
%   
%   % Visualize axial slice through center of transformed volume to see
%   % effect of scale transformation.
%   figure, imshowpair(A(:,:,14),outputImage(:,:,27));
%
%   See also AFFINE2D, PROJECTIVE2D, IMWARP

% Copyright 2012-2014 The MathWorks, Inc.

classdef affine3d < images.geotrans.internal.GeometricTransformation
        
    properties
       
        %T - Forward transformation matrix
        %
        %    T is a 4x4 floating point matrix that defines the forward
        %    transformation. The matrix T uses the convention:
        %
        %    [x y z 1] = [u v w 1] * T
        %
        %    Where T has the form:
        %
        %    [a b c 0;...
        %     d e f 0;...
        %     g h i 0;...
        %     j k l 1];
        T
                
    end
    
    properties (Dependent = true, Access = private, Hidden = true)
        
        %Tinv - Inverse transformation matrix
        %
        %    Tinv is a 4x4 floating point matrix that defines the inverse
        %    transformation. The matrix uses the convention:
        %
        %    [u v w 1] =  [x y z 1] * Tinv;
        %
        %    Where Tinv has the form:
        %
        %    [a b c 0;...
        %     d e f 0;...
        %     g h i 0;...
        %     j k l 1];
        Tinv
        
    end
    
    
    methods
        
        function self = affine3d(A)
            %affine3d Construct affine3d object
            %
            %   tform = affine3d() constructs an affine3d object with default
            %   property settings that correspond to the identity
            %   transformation.
            %
            %   tform = affine3d(A) constructs an affine3d object given an
            %   input 4x4 matrix A that specifies a valid 4x4 affine
            %   transformation matrix. A must be of the form:
            %
            %    A = [a b c 0;...
            %         d e f 0;...
            %         g h i 0;...
            %         j k l 1];
            
            if nargin ==0
                self.T = eye(4);
            else
                self.T = A; 
            end
            
            self.Dimensionality = 3;
                            
        end
        
        function varargout = transformPointsForward(self,varargin)
            %transformPointsForward Apply forward geometric transformation
            %
            %   [x,y,z] = transformPointsForward(tform,u,v,w)
            %   applies the forward transformation of tform to the input 3-D
            %   point arrays u,v,w and outputs the point arrays x,y,z. The
            %   input point arrays u,v, and w must be of the same size.
            %
            %   X = transformPointsForward(tform,U)
            %   applies the forward transformation of tform to the input
            %   Nx3 point matrix U and outputs the Nx3 point matrix X.
            %   transformPointsFoward maps the point U(k,:) to the point
            %   X(k,:).
            
            packedPointsSpecified = (nargin==2);
            if packedPointsSpecified
                
                U = varargin{1};
                validateattributes(U,{'single','double'},{'2d','nonsparse'},'images:affine3d:transformPointsForward','U');
                
                if ~isequal(size(U,2),3)
                    error(message('images:geotrans:transformPointsPackedMatrixInvalidSize3d',...
                        'transformPointsForward','U'));
                end
                
                % Append an all ones column to put U in homogeneous
                % coordinates for matrix multiply.
                U = padarray(U,[0 1],1,'post');
                
                X = U*self.T;
                varargout{1} = X(:,1:3);
                
            else
                
                narginchk(4,4);
                u = varargin{1};
                v = varargin{2};
                w = varargin{3};
                
                if ~isequal(size(u),size(v)) || ~isequal(size(v),size(w))
                    error(message('images:geotrans:transformPointsSizeMismatch3d','transformPointsForward','X','Y','Z'));
                end
                
                validateattributes(u,{'double','single'},{'nonsparse'},'images:affine3d:transformPointsForward','U');
                validateattributes(v,{'double','single'},{'nonsparse'},'images:affine3d:transformPointsForward','V');
                validateattributes(w,{'double','single'},{'nonsparse'},'images:affine3d:transformPointsForward','W');
                
                M = self.T;

                if(coder.target('MATLAB'))
                    M = double(M);
                    varargout{1} = imlincomb(M(1,1),u, M(2,1),v,  M(3,1),w,  M(4,1), class(self.T));
                    varargout{2} = imlincomb(M(1,2),u, M(2,2),v,  M(3,2),w,  M(4,2), class(self.T));
                    varargout{3} = imlincomb(M(1,3),u, M(2,3),v,  M(3,3),w,  M(4,3), class(self.T));
                else
                    varargout{1} = M(1,1).*u + M(2,1).*v + M(3,1).*w + M(4,1);
                    varargout{2} = M(1,2).*u + M(2,2).*v + M(3,2).*w + M(4,2);
                    varargout{3} = M(1,3).*u + M(2,3).*v + M(3,3).*w + M(4,3);
                end

            end
            
        end
        
        function varargout = transformPointsInverse(self,varargin)
            %transformPointsInverse Apply inverse geometric transformation
            %
            %   [u,v,w] = transformPointsInverse(tform,x,y,z)
            %   applies the inverse transformation of tform to the input 3-D
            %   point arrays x,y,z and outputs the point arrays u,v,w. The
            %   input point arrays x,y, and z must be of the same size.\
            %
            %   U = transformPointsInverse(tform,X)
            %   applies the inverse transformation of tform to the input
            %   Nx3 point matrix X and outputs the Nx3 point matrix U.
            %   transformPointsFoward maps the point X(k,:) to the point
            %   U(k,:).
            
            packedPointsSpecified = (nargin==2);
            if packedPointsSpecified
                
                X = varargin{1};
                validateattributes(X,{'single','double'},{'2d','nonsparse'},'images:affine3d:transformPointsInverse','X');
                
                if ~isequal(size(X,2),3)
                    error(message('images:geotrans:transformPointsPackedMatrixInvalidSize3d',...
                        'transformPointsInverse','X'));
                end
                
                % Append an all ones column to put U in homogeneous
                % coordinates for matrix multiply.
                X = padarray(X,[0 1],1,'post');
                
                U = X*self.Tinv;
                varargout{1} = U(:,1:3);
                
            else
                
                narginchk(4,4);
                x = varargin{1};
                y = varargin{2};
                z = varargin{3};
                
                if ~isequal(size(x),size(y)) || ~isequal(size(y),size(z))
                    error(message('images:geotrans:transformPointsSizeMismatch3d','transformPointsInverse','X','Y','Z'));
                end
                
                validateattributes(x,{'double','single'},{'nonsparse'},'images:affine3d:transformPointsInverse','X');
                validateattributes(y,{'double','single'},{'nonsparse'},'images:affine3d:transformPointsInverse','Y');
                validateattributes(z,{'double','single'},{'nonsparse'},'images:affine3d:transformPointsInverse','Z');
                
                M = self.Tinv;

                if(coder.target('MATLAB'))
                    M = double(M);
                    varargout{1} = imlincomb(M(1,1),x, M(2,1),y,  M(3,1),z,  M(4,1), class(self.Tinv));
                    varargout{2} = imlincomb(M(1,2),x, M(2,2),y,  M(3,2),z,  M(4,2), class(self.Tinv));
                    varargout{3} = imlincomb(M(1,3),x, M(2,3),y,  M(3,3),z,  M(4,3), class(self.Tinv));
                else
                    varargout{1} = M(1,1).*x + M(2,1).*y + M(3,1).*z + M(4,1);
                    varargout{2} = M(1,2).*x + M(2,2).*y + M(3,2).*z + M(4,2);
                    varargout{3} = M(1,3).*x + M(2,3).*y + M(3,3).*z + M(4,3);
                end
            end
            
        end
        
        function [xLimitsOut,yLimitsOut,zLimitsOut] = outputLimits(self,xLimitsIn,yLimitsIn,zLimitsIn)
            %outputLimits Find output limits of geometric transformation
            %
            %   [xLimitsOut,yLimitsOut,zLimitsOut] =
            %   outputLimits(tform,xLimitsIn,yLimitsIn,zLimitsIn) estimates
            %   the output spatial limits corresponding to a given
            %   geometric transformation and a set of input spatial limits.
            
            [xLimitsOut,yLimitsOut,zLimitsOut] = outputLimits@images.geotrans.internal.GeometricTransformation(self,...
                xLimitsIn,...
                yLimitsIn,...
                zLimitsIn);
            
        end
        
        function invtform = invert(self)
            %invert Invert geometric transformation
            %
            %   invtform = invert(tform) inverts the geometric
            %   transformation tform and returns the inverse geometric
            %   transform.
            
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

            % Check for expected symmetry in diagonal and off diagonal
            % elements.
            singularValues = svd(self.T(1:self.Dimensionality,1:self.Dimensionality));

            % For homogeneous scale, expect all singular values to be equal
            % within roughly eps of the largest singular value present.
            TF = max(singularValues)-min(singularValues) < 10*eps(max(singularValues(:)));

        end
                                                                              
    end
    
    methods
        % Set/Get methods
        function self = set.T(self,T)
                        
            validateattributes(T,{'single','double'},{'size',[4 4],'finite','nonnan'},...
                'affine3d.set.T',...
                'T');
            
            % Require that T is not singular
            if isequal(det(T),0)
                error(message('images:geotrans:singularTransformationMatrix'));
            end
            
            % Check last column of T
            if ~isequal(T(:,4),[0 0 0 1]')
                error(message('images:geotrans:invalidAffineMatrix'));
            end
            
            self.T = T;
            
        end
        
        function Tinv = get.Tinv(self)
           
            tinv = inv(self.T);
            tinv(:,end) = [0;0;0;1];
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
           
            self = affine3d(S.TransformationMatrix);
            
        end
        
    end
    
    methods (Static,Hidden)
        
        function TF = isvalid(T)
            %isvalid Determine if transformation matrix is valid
            %
            %   TF = affine3d.isvalid(T) determines whether the
            %   transformation matrix T is a valid parameterization of a
            %   3-D affine transformation. TF is true when T is a valid
            %   transformation matrix.
                        
            isSupportedClass = isa(T,'single') || isa(T,'double');
            
            TF = isSupportedClass && isequal(size(T),[4 4]) && all(isfinite(T(:))) && ~issparse(T) &&...
                ~isequal(det(T),0) && isequal(T(:,4),[0 0 0 1]');
            
        end
        
        
    end
        
end

