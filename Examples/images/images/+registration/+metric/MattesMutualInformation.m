%MattesMutualInformation Mutual information metric configuration object
%
%   A MutualInformation object describes a mutual information metric
%   configuration that can be passed to the function imregister to solve
%   image registration problems.
% 
%   metric = registration.metric.MattesMutualInformation() constructs a
%   MattesMutualInformation object. Larger values of mutual information
%   correspond to better registration results.
%
%   MattesMutualInformation properties:
%      NumberOfSpatialSamples - Number of spatial samples to used to compute metric   
%      NumberOfHistogramBins - Number of bins in the histogram
%      UseAllPixels - Whether all pixels are used to compute metric
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
%   See also registration.metric.MeanSquares, imregister

% Copyright 2011-2015 The MathWorks, Inc.

classdef MattesMutualInformation
     
    properties
        
        %NumberOfSpatialSamples Number of spatial samples used to compute
        %metric
        %
        %   NumberOfSpatialSamples is a positive scalar integer value that
        %   defines the number of random pixels used to compute the metric.
        %   This property is only used when UseAllPixels is false. More
        %   samples means longer computation time with improved run to run
        %   reproducibility of registration results.
        %
        %   Default: 500      
        NumberOfSpatialSamples
        
        %NumberOfHistogramBins Number of histogram bins used to compute
        %metric
        %
        %   NumberOfHistogramBins is a positive scalar integer value that
        %   defines the number of bins used in the joint histogram
        %   computation. The minimum value is 5.
        %
        %   Default: 50 
        NumberOfHistogramBins
        
        %UseAllPixels Controls whether all available pixels are used in the
        %computation of the metric.
        %
        %   UseAllPixels is a positive scalar integer value that controls
        %   whether all of the pixels in the overlapping region of the
        %   fixed and moving images are used to compute the metric. You can
        %   achieve significantly better performance by setting this
        %   property to false. When UseAllPixels is false, the
        %   NumberOfSpatialSamples property controls the number of random
        %   pixel locations that are used to compute the metric. When
        %   UseAllPixels is false, results from imregister may not be run
        %   to run reproducible due to the use of a random subset of pixels
        %   in the fixed and moving images to compute the metric.
        %
        %   Default: true
        UseAllPixels
                
    end
    
    methods

        function obj = MattesMutualInformation
            
            obj.NumberOfSpatialSamples = 500;
            obj.NumberOfHistogramBins  = 50;
            obj.UseAllPixels = true;
            
        end
        
        function obj = set.NumberOfSpatialSamples(obj,numSamples)
            validateattributes(numSamples,{'numeric'},{'real','positive','scalar','integer'});
            obj.NumberOfSpatialSamples = numSamples;
        end
        
        function obj = set.NumberOfHistogramBins(obj,numBins)
            validateattributes(numBins,{'numeric'},{'real','positive','scalar','integer','>=',5});
            obj.NumberOfHistogramBins = numBins;
        end
        
        function obj = set.UseAllPixels(obj,TF)
            validateattributes(TF,{'numeric','logical'},{'real','scalar','nonempty'});
            obj.UseAllPixels = logical(TF);
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
                fprintf('    <a href="matlab: help %s/NumberOfSpatialSamples">NumberOfSpatialSamples</a>: %d\n', mc.Name, this.NumberOfSpatialSamples);
                fprintf('     <a href="matlab: help %s/NumberOfHistogramBins">NumberOfHistogramBins</a>: %d\n', mc.Name, this.NumberOfHistogramBins);
                fprintf('              <a href="matlab: help %s/UseAllPixels">UseAllPixels</a>: %d\n', mc.Name, this.UseAllPixels);
            else
                fprintf('    NumberOfSpatialSamples: %d\n', this.NumberOfSpatialSamples);
                fprintf('     NumberOfHistogramBins: %d\n', this.NumberOfHistogramBins);
                fprintf('              UseAllPixels: %d\n', this.UseAllPixels);
            end
            
        end
        
    end
    
end

            
