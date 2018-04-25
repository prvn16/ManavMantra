classdef GeometricTransformation%#codegen
    %GeometricTransformation Base class for geometric transformations
    %
    %   The GeometricTransformation class formalizes
    %   the required interface for geometric transformations in the image
    %   processing toolbox. This class is an abstract base class.
    %
    %   GeometricTransformation properties:
    %      Dimensionality - Dimensionality of geometric transformation
    %
    %   GeometricTransformation methods:
    %      outputLimits - Find output spatial limits given input spatial limits
    %      transformPointsInverse (ABSTRACT) - Apply inverse 2-D geometric transformation to points
    %
    %   See also affine3d, projective2d
    
    % Copyright 2012-2014 The MathWorks, Inc.
    
    %#ok<*EMCA>
    
    methods (Abstract = true)
        
        % We apply all geometric transforms using reverse mapping. The
        % minimium requirement of all geometric transforms is that they
        % define transformPointsInverse.
        varargout = transformPointsInverse(varargin);
        
    end
    
    methods
        
        function varargout = outputLimits(self,xLimitsIn,yLimitsIn,zLimitsIn)
            %outputLimits Find output limits of geometric transformation
            %
            %   If Dimensionality == 2
            %
            %   [xLimitsOut,yLimitsOut] = outputLimits(tform,xLimitsIn,yLimitsIn) estimates the
            %   output spatial limits corresponding to a given geometric
            %   transformation and a set of input spatial limits.
            %
            %   If Dimensionality == 3
            %
            %   [xLimitsOut,yLimitsOut,zLimitsOut] = outputLimits(tform,xLimitsIn,yLimitsIn,zLimitsIn) estimates the
            %   output spatial limits corresponding to a given geometric
            %   transformation and a set of input spatial limits.
            
            coder.inline('always');
            
            if (self.Dimensionality == 2)
                
                narginchk(3,3)
                
                validateattributes(xLimitsIn,{'double'},{'size',[1 2],'finite','nonnan','nonempty'},'images.geotrans.internal.GeometricTransformation.outputLimits','xLimitsIn');
                validateattributes(yLimitsIn,{'double'},{'size',[1 2],'finite','nonnan','nonempty'},'images.geotrans.internal.GeometricTransformation.outputLimits','yLimitsIn');
                
                u = [xLimitsIn(1), mean(xLimitsIn), xLimitsIn(2)];
                v = [yLimitsIn(1), mean(yLimitsIn), yLimitsIn(2)];
                
                % Form grid of boundary points and internal points used by
                % findbounds algorithm.
                [U,V] = meshgrid(u,v);
                
                if ismethod(self,'transformPointsForward');
                    % Transform gridded points forward
                    [X,Y] = transformPointsForward(self,U,V);
                    
                else
                    % If the forward transformation is not defined, use
                    % numeric optimization to estimate the output bounds
                    [X,Y] = estimateForwardMapping(self,U,V);  
                end
                
                % XLimitsOut/YLimitsOut are formed from min and max of transformed points.
                varargout{1} = [min(X(:)), max(X(:))];
                varargout{2} = [min(Y(:)), max(Y(:))];
                
            else %(self.Dimensionality == 3)
                
                narginchk(4,4)
                
                validateattributes(xLimitsIn,{'double'},{'size',[1 2],'finite','nonnan','nonempty'},'images.geotrans.internal.GeometricTransformation.outputLimits','xLimitsIn');
                validateattributes(yLimitsIn,{'double'},{'size',[1 2],'finite','nonnan','nonempty'},'images.geotrans.internal.GeometricTransformation.outputLimits','yLimitsIn');
                validateattributes(zLimitsIn,{'double'},{'size',[1 2],'finite','nonnan','nonempty'},'images.geotrans.internal.GeometricTransformation.outputLimits','zLimitsIn');
                
                u = [xLimitsIn(1), mean(xLimitsIn), xLimitsIn(2)];
                v = [yLimitsIn(1), mean(yLimitsIn), yLimitsIn(2)];
                w = [zLimitsIn(1), mean(zLimitsIn), zLimitsIn(2)];
                
                % Form grid of boundary points and internal points used by
                % findbounds algorithm.
                [U,V,W] = meshgrid(u,v,w);
                
                % Transform gridded points forward
                [X,Y,Z] = transformPointsForward(self,U,V,W);
                
                % XLimitsOut/YLimitsOut are formed from min and max of transformed points.
                varargout{1} = [min(X(:)), max(X(:))];
                varargout{2} = [min(Y(:)), max(Y(:))];
                varargout{3} = [min(Z(:)), max(Z(:))];
                
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function [X,Y] = estimateForwardMapping(self,U,V) 
            
            coder.inline('always');
            coder.internal.prefer_const(self,U,V);
            
            % Turn off textual display during optimization.
            options = optimset('Display','off');
            
            [X,Y] = deal(zeros(size(U)));

            for i = 1:numel(U)
                
                u0 = [U(i) V(i)];
                objective_function = @(x,u0, self) norm(u0 - self.transformPointsInverse(x));
                
                [x,~,exitflag] = fminsearch(objective_function, u0, options, u0, self);
                
                optimizationFailed = exitflag <=0;
                if optimizationFailed
                    X = U;
                    Y = V;
                    warning(message('images:geotrans:estimateOutputBoundsFailed'));
                    break;
                else
                    X(i) = x(1);
                    Y(i) = x(2);
                end
                
            end
            
        end
         
    end
    
    properties (SetAccess = 'protected')
        
        %Dimensionality - Dimensionality of geometric transformation
        %
        %    Dimensionality describes the dimensionality of the geometric
        %    transformation for both input and output points.
        Dimensionality
        
    end
    
    
end

