%projective2d 2-D Projective Geometric Transformation
%
%   A projective2d object encapsulates a 2-D projective geometric transformation. 
%
%   projective2d properties:
%      T - 3x3 matrix representing forward projective transformation
%      Dimensionality - Dimensionality of geometric transformation
%
%   projective2d methods:
%      invert - Invert geometric transformation
%      outputLimits - Find output spatial limits given input spatial limits
%      projective2d - Construct projective2d object
%      transformPointsForward - Apply forward 2-D geometric transformation to points
%      transformPointsInverse - Apply inverse 2-D geometric transformation to points
%
%   Example 1
%   ---------
%   % Construct a projective2d object
%   theta = 10;
%   tform = projective2d([cosd(theta) -sind(theta) 0.001; sind(theta) cosd(theta) 0.01; 0 0 1]);
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
%   % Apply projective transformation to an image using the function imwarp
%   A = imread('pout.tif');
%   theta = 10;
%   tform = projective2d([cosd(theta) -sind(theta) 0.001; sind(theta) cosd(theta) 0.01; 0 0 1]);
%   outputImage = imwarp(A,tform);
%   figure, imshow(outputImage);
%
%   See also affine2d, affine3d, IMWARP

% Copyright 2012-2014 The MathWorks, Inc.

%#ok<*EMCA>

classdef projective2d < images.geotrans.internal.GeometricTransformation %#codegen
    properties
       
        %T - Forward transformation matrix
        %
        %    T is a 3x3 floating point matrix that defines the forward
        %    transformation. The matrix T uses the convention:
        %
        %    [x y 1] = [u v 1] * T
        %
        %    Where T has the form:
        %
        %    [a b c;...
        %     d e f;...
        %     g h i];
        T
                
    end
    
    properties (Dependent = true, Access = private, Hidden = true)
        
        %Tinv - Inverse transformation matrix
        %
        %    Tinv is a 3x3 floating point matrix that defines the inverse
        %    transformation. The matrix uses the convention:
        %
        %    [u v 1] =  [x y 1] * Tinv;
        %
        %    Where Tinv has the form:
        %
        %    [a b c;
        %     d e f;
        %     g h i];
        Tinv
        
    end
    
        
    methods
        
        function self = projective2d(A)
            %projective2d Construct projective2d object
            %
            %   tform = projective2d() constructs a projective2d object with default
            %   property settings that correspond to the identity
            %   transformation.
            %
            %   tform = projective2d(A) constructs a projective2d object given an
            %   input 3x3 matrix A that specifies a valid 3x3 projective
            %   transformation matrix. A must be of the form:
            %
            %    A = [a b c;
            %         d e f;
            %         g h i];
            
            coder.inline('always');
            
            if nargin ==0
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
                validateattributes(U,{'single','double'},{'2d','nonsparse'},...
                    'images:projective2d:transformPointsForward','U');
                
                
                coder.internal.errorIf( ~isequal(size(U,2),2),...
                    'images:geotrans:transformPointsPackedMatrixInvalidSize',...
                    'transformPointsForward','U');
                
                % Append an all ones column to put U in homogeneous
                % coordinates for matrix multiply.
                U = padarray(U,[0 1],1,'post');
                
                X = U*self.T;
                if isempty(X)
                    varargout{1} = zeros(0,2,'like',X);
                else
                    X(:,1:2) = X(:,1:2)./repmat(X(:,3),[1 2]);
                    varargout{1} = X(:,1:2);
                end
                
                
            else
                
                narginchk(3,3);
                u = varargin{1};
                v = varargin{2};
                
                coder.internal.errorIf(~isequal(size(u),size(v)),...
                    'images:geotrans:transformPointsSizeMismatch',...
                    'transformPointsForward','U','V');
                
                validateattributes(u,{'double','single'},{'nonsparse'},'images:projective2d:transformPointsForward','U');
                validateattributes(v,{'double','single'},{'nonsparse'},'images:projective2d:transformPointsForward','V');
                
                M = self.T;
                
                if(coder.target('MATLAB'))
                    M = double(M);
                    x = imlincomb(M(1,1),u, M(2,1),v,  M(3,1), class(self.T));
                    y = imlincomb(M(1,2),u, M(2,2),v,  M(3,2), class(self.T));
                    z = imlincomb(M(1,3),u, M(2,3),v,  M(3,3), class(self.T)); 
                else
                    x = M(1,1).*u + M(2,1).*v + M(3,1);
                    y = M(1,2).*u + M(2,2).*v + M(3,2);
                    z = M(1,3).*u + M(2,3).*v + M(3,3);          
                end
                
                varargout{1} = x ./ z;
                varargout{2} = y ./ z;
                
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
                validateattributes(X,{'single','double'},{'2d','nonsparse'},'images:projective2d:transformPointsInverse','X');
                
                coder.internal.errorIf(~isequal(size(X,2),2),...
                    'images:geotrans:transformPointsPackedMatrixInvalidSize',...
                    'transformPointsInverse','X');
                
                % Append an all ones column to put X in homogeneous
                % coordinates for matrix multiply.
                X = padarray(X,[0 1],1,'post');
                
                U = X*self.Tinv;
                if isempty(U)
                    varargout{1} = zeros(0,2,'like',U);
                else
                    U(:,1:2) = U(:,1:2)./repmat(U(:,3),[1 2]);
                    varargout{1} = U(:,1:2);
                end
                
                
            else
                
                narginchk(3,3);
                x = varargin{1};
                y = varargin{2};
                
                coder.internal.errorIf(~isequal(size(x),size(y)),...
                    'images:geotrans:transformPointsSizeMismatch',...
                    'transformPointsInverse','X','Y');
                
                validateattributes(x,{'double','single'},{'nonsparse'},'images:projective2d:transformPointsInverse','X');
                validateattributes(y,{'double','single'},{'nonsparse'},'images:projective2d:transformPointsInverse','Y');
                
                M = self.Tinv;
                
                if(coder.target('MATLAB'))
                    M = double(M);
                    u = imlincomb(M(1,1),x, M(2,1),y,  M(3,1), class(self.Tinv));
                    v = imlincomb(M(1,2),x, M(2,2),y,  M(3,2), class(self.Tinv));
                    w = imlincomb(M(1,3),x, M(2,3),y,  M(3,3), class(self.Tinv));
                else
                    u = M(1,1).*x + M(2,1).*y + M(3,1);
                    v = M(1,2).*x + M(2,2).*y + M(3,2);
                    w = M(1,3).*x + M(2,3).*y + M(3,3);
                end
                
                varargout{1} = u ./ w;
                varargout{2} = v ./ w;
                
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
                                                                      
    end
    
    methods
        % Set/Get methods
        function self = set.T(self,T)
                
            coder.inline('always');
            coder.internal.prefer_const(self,T);
            
            % Validate size and that T is finite
            validateattributes(T,...
                {'single','double'},{'size',[3 3],'finite','nonnan'},...
                'projective2d.set.T',...
                'T');

            % Also require that T is non-singular.
            coder.internal.errorIf(isequal(det(T),0),...
                'images:geotrans:singularTransformationMatrix');
        
            self.T = T;
            
        end
        
        function Tinv = get.Tinv(self)
           
            coder.inline('always');
            coder.internal.prefer_const(self);
            
            % Always calculate inverse transformation matrix in
            % double-precision
            if isa(self.T,'single')
                Tinv = single(inv(double(self.T)));
            else
                Tinv = inv(self.T);
            end
                
            
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
           
            self = projective2d(S.TransformationMatrix);
            
        end
        
    end
    
    methods (Static,Hidden)
        
        function TF = isvalid(T)
            %isvalid Determine if transformation matrix is valid
            %
            %   TF = projective2d.isvalid(T) determines whether the
            %   transformation matrix T is a valid parameterization of a
            %   2-D projective transformation. TF is true when T is a valid
            %   transformation matrix.
           
            coder.inline('always');
            coder.internal.prefer_const(T);
            
            isSupportedClass = isa(T,'single') || isa(T,'double');
            
            TF = isSupportedClass && isequal(size(T),[3 3]) && all(isfinite(T(:))) && ~issparse(T) &&...
                ~isequal(det(T),0);
            
        end
                
    
    end
        
end

