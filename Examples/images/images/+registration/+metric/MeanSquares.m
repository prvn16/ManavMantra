%MeanSquares Mean square error metric configuration object
%
%   A MeanSquares object describes a mean square error metric configuration
%   that can be passed to the function imregister to solve image
%   registration problems. The metric is an element-wise difference between
%   two input images. The ideal value of the metric is zero.
% 
%   metric = registration.metric.MeanSquares() constructs a MeanSquares
%   object.
%
%   Example
%   -------
%   % Read in two remote sensing images of the same scene taken at
%   % different times with different sensors from slightly different
%   % perspectives. (Note: IMREGISTER doesn't support perspective
%   % transformations, but it still gives good results for this problem
%   % using a similarity transformation.) 
%   fixed  = imread('westconcordorthophoto.png');
%   moving = rgb2gray(imread('westconcordaerial.png'));
%
%   % View misaligned images
%   imshowpair(fixed, moving,'Scaling','joint');
%
%   % Even though images came from different sensors, images have
%   % an intensity relationship similar enough to use mean square
%   % error as the similarity metric.
%   optimizer = registration.optimizer.OnePlusOneEvolutionary;
%   metric    = registration.metric.MeanSquares;
%
%   % Tune the properties of the optimizer to allow for more iterations.
%   optimizer.MaximumIterations = 1000;
%
%   % Align the moving image with the fixed image
%   movingRegistered = imregister(moving, fixed, 'similarity', optimizer, metric);
%
%   % View registered images
%   figure
%   imshowpair(fixed, movingRegistered,'Scaling','joint');
%
%   See also registration.metric.MattesMutualInformation, imregister

% Copyright 2011-2015 The MathWorks, Inc.

classdef MeanSquares
     
    properties
        % No properties.  
      
    end
    
    methods

        function obj = MeanSquares
            % Only offer default flavor of MeanSquaresImageToImageMetric.
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
            
            str = getString(message('images:imregister:hasNoProperties'));
            fprintf('\n  %s\n',str);
            
%             % Print links for methods and superclasses
%             if feature('hotlinks')
%                 fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ', mc.Name);
%                 fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n', mc.Name);
%             end
            
        end
        
    end
    
end

            
