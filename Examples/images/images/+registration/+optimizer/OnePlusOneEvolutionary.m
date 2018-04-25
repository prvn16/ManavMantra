%OnePlusOneEvolutionary One-plus-one evolutionary optimizer configuration object
%
%   A OnePlusOneEvolutionary object describes a one-plus-one evolutionary
%   optimization configuration that can be passed to the function
%   imregister to solve image registration problems.
% 
%   optimizer = registration.optimizer.OnePlusOneEvolutionary() constructs
%   a OnePlusOneEvolutionary object.
%
%   OnePlusOneEvolutionary properties:
%      GrowthFactor - Growth factor of search radius
%      Epsilon - Minimal size of search radius
%      InitialRadius - Initial size of search radius
%      MaximumIterations - Maximum number of iterations
%      
%   Example
%   -------
%   % Read in two slightly misaligned magnetic resonance images of a knee
%   % obtained using different protocols.
%   fixed  = dicomread('knee1.dcm');
%   moving = dicomread('knee2.dcm');
%
%   % View misaligned images
%   imshowpair(fixed, moving,'Scaling','joint');
%
%   % Get a configuration suitable for registering images from different
%   % sensors.
%   optimizer = registration.optimizer.OnePlusOneEvolutionary;
%   metric    = registration.metric.MattesMutualInformation;
%
%   % Tune the properties of the optimizer to get the problem to converge
%   % on a global maxima and to allow for more iterations.
%   optimizer.InitialRadius = 0.009;
%   optimizer.Epsilon = 1.5e-4;
%   optimizer.GrowthFactor = 1.01;
%   optimizer.MaximumIterations = 300;
%
%   % Align the moving image with the fixed image
%   movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
%
%   % View registered images
%   figure
%   imshowpair(fixed, movingRegistered,'Scaling','joint');
%
%   See also registration.optimizer.RegularStepGradientDescent, imregister

% Copyright 2011-2015 The MathWorks, Inc.

classdef OnePlusOneEvolutionary
    
    properties
      
        %GrowthFactor Search radius grow factor
        %
        %   GrowthFactor is a positive scalar value that controls the rate
        %   at which the search radius grows in parameter space. For a big
        %   GrowthFactor, the optimization is fast, but more likely to end
        %   in a local minimum. The choice of smaller values of
        %   GrowthFactor leads to slower optimization.
        %
        %   Default: 1.05
        GrowthFactor
                
        %Epsilon Minimal size of search radius
        %
        %   Epsilon is a positive scalar value that controls the accuracy
        %   of convergence by adjusting the minimal size of the search
        %   radius. The choice of smaller values of Epsilon may lead to
        %   more accurate optimization of the metric at the expense of
        %   slower convergence.
        %
        %   Default: 0.0000015
        Epsilon
        
        %InitialRadius Initial search radius
        %
        %   InitialRadius is a positive scalar value that controls the
        %   initial search radius of the optimizer. Increasing
        %   InitialRadius can lead to faster convergence. Overly large
        %   values of InitialRadius may fail to converge.
        %
        %   Default: 0.00625
        InitialRadius
        
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
        
    end
    
    properties (Hidden)
        % Both mutual information and mean squares are minimization
        % problems (mattesMutualInformationImageToImageMetriic returns
        % -MI). We don't actually need to expose this property at all for
        % the current set of metrics. For now make it hidden.
        
        % We might consider defining these hidden properties in a common
        % base class since all optimizer configs will need to define these
        % properties.
        
        Minimize
        Scales
        
    end
    
    properties (Dependent = true, SetAccess = private, Hidden)
        
        ShrinkFactor
        
    end
    
    methods
       
        function obj = OnePlusOneEvolutionary
            
            obj.GrowthFactor      = 1.05;
            obj.Epsilon           = 1.5e-6;
            obj.InitialRadius     = 6.25e-3;
            obj.Minimize          = true;
            obj.MaximumIterations = 100;
            obj.Scales            = zeros(1,0);
            
        end
        
        function obj = set.GrowthFactor(obj,GF)
           
            validateattributes(GF,{'numeric'},{'positive','real','scalar'});
            if GF <= 1
                error(message('images:OnePlusOneEvolutionary:growthFactorRange'));
            end
            
            obj.GrowthFactor = GF;
            
        end
        
        function shrink_factor = get.ShrinkFactor(obj)
            % For now, treat ShrinkFactor as dependent property based on
            % recommendation in (Styner,1997) and ITK implementation.
            shrink_factor = obj.GrowthFactor ^ -0.25;
        
        end
     
        function obj = set.InitialRadius(obj,initRadius)
            
            validateattributes(initRadius,{'numeric'},{'positive','real','scalar'});
            obj.InitialRadius = initRadius;
            
        end
        
        function obj = set.Epsilon(obj,epsRadius)
            
            validateattributes(epsRadius,{'numeric'},{'positive','real','scalar'});
            obj.Epsilon = epsRadius;
            
        end
        
        % These set methods also could be moved into a common base class
        % (this would require using a common property name across all
        % optimizers, even though this property name varies in the actual
        % ITK interface).
        function obj = set.MaximumIterations(obj,maxIters)
            
            validateattributes(maxIters,{'numeric'},{'positive','real','scalar','integer'});
            obj.MaximumIterations = maxIters;
            
        end
        
        % These set methods also could be moved into a common base class
        function obj = set.Scales(obj,scales)
            
            validateattributes(scales,{'numeric'},{'positive','real', 'vector'});
            obj.Scales = scales;
            
        end
        
        % These set methods also could be moved into a common base class
        function obj = set.Minimize(obj,TF)
            
            validateattributes(TF,{'numeric','logical'},{'real','scalar'});
            obj.Minimize = TF;
            
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
                fprintf('         <a href="matlab: help %s/GrowthFactor">GrowthFactor</a>: %d\n', mc.Name, this.GrowthFactor);
                fprintf('              <a href="matlab: help %s/Epsilon">Epsilon</a>: %d\n', mc.Name, this.Epsilon);
                fprintf('        <a href="matlab: help %s/InitialRadius">InitialRadius</a>: %d\n', mc.Name, this.InitialRadius);
                fprintf('    <a href="matlab: help %s/MaximumIterations">MaximumIterations</a>: %d\n', mc.Name, this.MaximumIterations);
            else
                fprintf('         GrowthFactor: %d\n', this.GrowthFactor);
                fprintf('              Epsilon: %d\n', this.Epsilon);
                fprintf('        InitialRadius: %d\n', this.InitialRadius);
                fprintf('    MaximumIterations: %d\n', this.MaximumIterations);
            end
            
%             % Print links for methods and superclasses
%             if feature('hotlinks')
%                 fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ', mc.Name);
%                 fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n', mc.Name);
%             end
            
        end
        
    end
    
end
