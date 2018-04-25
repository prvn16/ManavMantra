classdef Demons2D
    
    %   Copyright 2014 The MathWorks, Inc.

    
    properties (Access = private, Constant)
        
        % Numerics thresholds used to force convergence of update field in
        % numerically unstable cases.
        IntensityDifferenceThreshold = 0.001;
        DenominatorThreshold = 1e-9;
        
    end
    
    properties (Access = private)
        
        % Warped version of moving image
        MovingWarped
        
        % World coordinates of fixed grid
        xIntrinsicFixed
        yIntrinsicFixed
        
        % Standard deviation of gaussian filter used to regularize
        % accumulated displacement field after each iteration
        Sigma
        
        % spatial domain representation of guassian filter used to regularize
        % the field
        hGaussian
                
        % Gradient computations on the fixed image that drive the demons
        FgradX
        FgradY
        FgradMagSquared
                
    end
        
    properties (Access = protected)
        
        %Accumulated displacement field, x and y components
        Da_x
        Da_y
        
        %Moving Image
        Moving
                
        %Fixed Image
        Fixed
                
    end
    
    
    methods
        
        function self = Demons2D(moving,fixed,sigma)
            
            % Use internal double precision floating point representation
            % of images when computing demons
            self.Moving = double(moving);
            self.Fixed  = double(fixed);
            self.MovingWarped = self.Moving;
            
            self.Sigma = sigma;
            
            % Initialize displacement field to all zeros (identity
            % transformation)
            [self.Da_x,self.Da_y] = deal(zeros(size(fixed)));
                        
        end
        
        function self = set.Sigma(self,SigmaNew)
            
           self.Sigma = SigmaNew;
           self = self.computeGaussianKernel(self.Sigma);
            
        end
        
        function self = computeGaussianKernel(self,sigma)
            
            % Choose d such that gaussian used for regularization is odd length of at least 3 sigma in
            % extent from the center in each direction.
            r = ceil(3*sigma);
            d = 2*r+1;
            
            self.hGaussian = fspecial('gaussian',[d d],sigma);
            
        end
        
        function self = set.Fixed(self,FixedNew)
            
            self.Fixed = FixedNew;
            
            % Compute Gradient of fixed image.
            self = self.computeFixedGradient();
            
            % Plaid representation of fixed grid in the intrinsic coordinate
            % system
            [self.xIntrinsicFixed,self.yIntrinsicFixed] = meshgrid(1:size(FixedNew,2),1:size(FixedNew,1));
             
        end
                
                        
        function self = computeFixedGradient(self)
            
            % Compute gradient of F one time on initialization in classic
            % Thirion demons.
            [self.FgradX,self.FgradY] = imgradientxy(self.Fixed,'CentralDifference');
            self.FgradMagSquared = self.FgradX.^2+self.FgradY.^2;
            
        end
        
        function self = iterate(self,numIterations)
            
            for i = 1:numIterations
                                
                self.MovingWarped = interp2dLocal(self.Moving,...
                    self.xIntrinsicFixed+self.Da_x,...
                    self.yIntrinsicFixed+self.Da_y);
                
                FixedMinusMovingWarped = self.Fixed-self.MovingWarped;
                denominator =  (self.FgradMagSquared + FixedMinusMovingWarped.^2);
                
                % Compute additional displacement field - Thirion
                directionallyConstFactor = FixedMinusMovingWarped ./ denominator;
                Du_x = directionallyConstFactor .* self.FgradX;
                Du_y = directionallyConstFactor .* self.FgradY;
                
                zeroUpdateLocations = (abs(FixedMinusMovingWarped) < self.IntensityDifferenceThreshold) |...
                    (denominator < self.DenominatorThreshold) |...
                    isnan(self.MovingWarped);
                
                Du_x(zeroUpdateLocations) = 0;
                Du_y(zeroUpdateLocations) = 0;
                
                % Compute total displacement vector - additive update
                self.Da_x = self.Da_x + Du_x;
                self.Da_y = self.Da_y + Du_y;
                
                % Regularize vector field by gaussian smoothing.
                self.Da_x = imfilter(self.Da_x, self.hGaussian,'replicate');
                self.Da_y = imfilter(self.Da_y, self.hGaussian,'replicate');
                
            end
            
        end
        
        
    end
    
    
end

function out = interp2dLocal(moving,Uintrinsic,Vintrinsic)
% Implements local, optimized version of images.internal.interp2d that does
% no input parsing for the remapmex codepath and does no smoothing at the
% image boundaries which interpolating the intermediate warped moving
% image.

% Use NaN fill value to mark MovingWarped locations that
% were formed from out of bounds query locations. These can
% be later identified as zeroUpdateLocations using a simple
% isnan check.
if ippl
    out = images.internal.remapmex(moving,Uintrinsic-1,Vintrinsic-1,'linear',NaN);
else
    out = interp2(moving,Uintrinsic,Vintrinsic,'linear',NaN);
end

end

