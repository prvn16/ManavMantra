%RegularStepGradientDescent Regular step gradient descent optimizer configuration object
%
%   A RegularStepGradientDescent object describes a regular step gradient
%   descent optimization configuration that can be passed to the function
%   imregister to solve image registration problems.
% 
%   optimizer = registration.optimizer.RegularStepGradientDescent()
%   constructs a RegularStepGradientDescent object.
%
%   RegularStepGradientDescent properties:
%      GradientMagnitudeTolerance - Tolerance for plateau checking
%      MinimumStepLength - Tolerance for convergence
%      MaximumStepLength - Initial step length
%      MaximumIterations - Maximum number of iterations
%      RelaxationFactor - Controls relaxation of step length
%
%   Example
%   -------
%   fixed  = imread('pout.tif');
%   moving = imrotate(fixed, 5, 'bilinear', 'crop');
%
%   % View misaligned images
%   imshowpair(fixed, moving,'Scaling','joint');
%
%   % Get a configuration suitable for registering images from the
%   % same sensor.  Modify the configuration to get more precision.
%   optimizer = registration.optimizer.RegularStepGradientDescent;
%   metric = registration.metric.MeanSquares;
%   optimizer.MaximumIterations = 300;
%   optimizer.MinimumStepLength = 5e-4;
%
%   % Align moving image with the fixed image.
%   movingRegistered = imregister(moving, fixed, 'rigid', optimizer, metric);
%
%   % View registered images
%   figure
%   imshowpair(fixed, movingRegistered,'Scaling','joint');
%
%   See also registration.optimizer.OnePlusOneEvolutionary, imregister

% Copyright 2011-2015 The MathWorks, Inc.

classdef RegularStepGradientDescent
    
    
    properties
        
        %GradientMagnitudeTolerance Gradient magnitude tolerance of the optimizer
        %
        %   GradientMagnitudeTolerance is a positive scalar value that
        %   controls the optimization process. When the value of the gradient
        %   is smaller than this tolerance, it is an indication that the
        %   cost function may have reached a plateau.
        %
        %   Default: 1e-4
        GradientMagnitudeTolerance
        
        %MinimumStepLength Minimum step length of the optimizer
        %
        %   MinimumStepLength is a positive scalar value that controls the
        %   accuracy of convergence. The choice of smaller values may lead
        %   to more accurate optimization of the metric at the expense of
        %   slower convergence.
        %    
        %   Default: 1e-5
        MinimumStepLength
        
        %MaximumStepLength Maximum step length of the optimizer
        %
        %   MaximumStepLength is a positive scalar value that controls the
        %   initial step length used in optimization. Increasing
        %   MaximumStepLength can lead to faster convergence. Overly large
        %   values of MaximumStepLength may fail to converge.
        %
        %   Default: 0.0625
        MaximumStepLength
        
        %MaximumIterations Maximum number of iterations of the optimizer
        %
        %   MaximumIterations is a positive scalar integer value that
        %   determines the maximum number of iterations per pyramid level
        %   that may be performed by the optimizer during registration. The
        %   registration may converge before the maximum number of
        %   iterations is reached.
        %
        %   Default: 100
        MaximumIterations
        
        %RelaxationFactor Relaxation factor of the optimizer
        %
        %   RelaxationFactor is a scalar value in the range (0,1) that
        %   defines the rate at which the optimizer step size is reduced
        %   during convergence. Whenever the optimizer encounters that the
        %   direction of movement has changed in parameter space, it
        %   reduces the size of the step length. For noisy metrics, larger
        %   relaxation factors will lead to more stable convergence at the
        %   expense of increased computation time.
        %  
        %   Default: 0.5    
        RelaxationFactor
        
    end
    
    properties (Hidden)
        % Both mutual information and mean squares are minimization
        % problems (mattesMutualInformationImageToImageMetriic returns
        % -MI). We don't actually need to expose this property at all for
        % the current set of metrics. For now make it hidden.
        
        Minimize
        Scales

    end
     
    methods  % Public methods
        
        function obj = RegularStepGradientDescent

           obj.GradientMagnitudeTolerance = 1e-4;
           obj.Minimize                   = true;
           obj.MinimumStepLength          = 1e-5;
           obj.MaximumStepLength          = 6.25e-2;
           obj.MaximumIterations          = 100;
           obj.RelaxationFactor           = 5e-1;
           obj.Scales                     = zeros(0,1);

        end
        
        function obj = set.GradientMagnitudeTolerance(obj,tol)
        
           validateattributes(tol,{'numeric'},{'positive','real','scalar'});
           obj.GradientMagnitudeTolerance = tol;
            
        end
        
        function obj = set.Minimize(obj,TF)
            
            validateattributes(TF,{'numeric','logical'},{'real','scalar'});
            obj.Minimize = TF;
            
        end
        
        function obj = set.MinimumStepLength(obj,minStepLength)
            
            validateattributes(minStepLength,{'numeric'},{'positive','real','scalar'});
            obj.MinimumStepLength = minStepLength;
            
        end
        
        function obj = set.MaximumStepLength(obj,maxStepLength)
            
            validateattributes(maxStepLength,{'numeric'},{'positive','real','scalar'});
            obj.MaximumStepLength = maxStepLength;
            
        end
        
        function obj = set.MaximumIterations(obj,numIters)
            
            validateattributes(numIters,{'numeric'},{'positive','real','scalar','integer'});
            obj.MaximumIterations = numIters;
            
        end
        
        function obj = set.RelaxationFactor(obj,relaxFactor)
            
            validateattributes(relaxFactor,{'numeric'},{'positive','real','scalar','<',1.0});    
            obj.RelaxationFactor = relaxFactor;
            
        end
        
        function obj = set.Scales(obj,scales)
            
            validateattributes(scales,{'numeric'},{'positive','real', 'vector'});
            obj.Scales = scales;
            
        end
        
        
    end
    
    methods (Hidden = true)
        
        function disp(this)

            % Print the class name
            mc = metaclass(this);
            if feature('hotlinks')
                fprintf('  <a href="matlab: help %s">%s</a>\n', mc.Name, mc.Name);
            else
                fprintf('  %s\n', mc.Name);
            end
            
            str = getString(message('images:imregister:properties'));
            fprintf('\n  %s:\n',str);
            
            if feature('hotlinks')
                fprintf('    <a href="matlab: help %s/GradientMagnitudeTolerance">GradientMagnitudeTolerance</a>: %d\n', mc.Name, this.GradientMagnitudeTolerance);
                fprintf('             <a href="matlab: help %s/MinimumStepLength">MinimumStepLength</a>: %d\n', mc.Name, this.MinimumStepLength);
                fprintf('             <a href="matlab: help %s/MaximumStepLength">MaximumStepLength</a>: %d\n', mc.Name, this.MaximumStepLength);
                fprintf('             <a href="matlab: help %s/MaximumIterations">MaximumIterations</a>: %d\n', mc.Name, this.MaximumIterations);
                fprintf('              <a href="matlab: help %s/RelaxationFactor">RelaxationFactor</a>: %d\n', mc.Name, this.RelaxationFactor);

            else
                fprintf('    GradientMagnitudeTolerance: %d\n', this.GradientMagnitudeTolerance);
                fprintf('             MinimumStepLength: %d\n', this.MinimumStepLength);
                fprintf('             MaximumStepLength: %d\n', this.MaximumStepLength);
                fprintf('             MaximumIterations: %d\n', this.MaximumIterations);
                fprintf('              RelaxationFactor: %d\n', this.RelaxationFactor);

            end
            
%             % Print links for methods and superclasses
%             if feature('hotlinks')
%                 fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ', mc.Name);
%                 fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n', mc.Name);
%             end
            
        end
        
    end

end

            
