classdef Demons3D
    
    %   Copyright 2014 The MathWorks, Inc.

    properties (Constant, Access = private)
        
        % Numerics thresholds used to force convergence of update field in
        % numerically unstable cases.
        IntensityDifferenceThreshold = 0.001;
        DenominatorThreshold = 1e-9;
        
    end
        
    properties (Access = private)
        
        % Warped version of moving image
        MovingWarped
                                
        % Standard deviation of gaussian filter used to regularize
        % accumulated displacement field after each iteration
        Sigma
        
        % spatial domain representation of guassian filter used to regularize
        % the field
        hGaussian
        
        % Gradient computations on the fixed image that drive the demons
        FgradX
        FgradY
        FgradZ
        FgradMagSquared
        
        % Intrinsic coordinates of fixed grid
        xIntrinsicFixed
        yIntrinsicFixed
        zIntrinsicFixed
        
    end
    
    properties (Access = protected)
        
        %Accumulated displacement field components
        Da_x
        Da_y
        Da_z
        
        %Moving Image
        Moving
        
        %Fixed Image
        Fixed
        
    end
    
    methods
        
        function self = computeFixedGradient(self)
            
            % Compute gradient of F one time on initialization in classic
            % Thirion demons.
            [self.FgradX,self.FgradY,self.FgradZ] = gradient(self.Fixed);
            self.FgradMagSquared = self.FgradX.^2+self.FgradY.^2 + self.FgradZ.^2;
            
        end
        
        function self = set.Fixed(self,FixedNew)
            
            self.Fixed = FixedNew;
            
            % Compute Gradient of fixed image.
            self = self.computeFixedGradient();
            
            % Plaid representation of fixed grid in the intrinsic coordinate
            % system
            [self.xIntrinsicFixed,self.yIntrinsicFixed,self.zIntrinsicFixed] = meshgrid(1:size(self.Fixed,2),...
                1:size(self.Fixed,1),1:size(self.Fixed,3));
            
        end
        
        
        function self = Demons3D(moving,fixed,sigma)
            
            % Use internal double precision floating point representation
            % of images when computing demons
            self.Moving = double(moving);
            self.Fixed  = double(fixed);
            self.MovingWarped = self.Moving;
            
            self.Sigma = sigma;
           
            % Initialize displacement field to all zeros (identity
            % transformation)
            [self.Da_x,self.Da_y,self.Da_z] = deal(zeros(size(fixed)));
            
            % Choose d such that gaussian used for regularization is odd length of at least 3 sigma in
            % extent from the center in each direction.
            self = computeGaussianKernel(self,sigma);
                         
        end
        
        function self = computeGaussianKernel(self,sigma)
            
            % Choose d such that gaussian used for regularization is odd length of at least 3 sigma in
            % extent from the center in each direction.
            r = ceil(3*sigma);
            d = 2*r+1;

            self.hGaussian = fspecial('gaussian',[1 d],sigma);
            
        end
        
        function self = iterate(self,numIterations)
            
            for i = 1:numIterations
                                
                % Form the intermediate warped resampled image without any
                % input parsing or boundary smoothing to maximize
                % performance in each iteration.
                % 
                % Use NaN fill value to mark MovingWarped locations that
                % were formed from out of bounds query locations. These can
                % be later identified as zeroUpdateLocations using a simple
                % isnan check.
                self.MovingWarped = images.internal.interp3dmex(self.Moving,...
                    self.xIntrinsicFixed+self.Da_x,...
                    self.yIntrinsicFixed+self.Da_y,...
                    self.zIntrinsicFixed+self.Da_z,...
                    NaN);
                
                FixedMinusMovingWarped = (self.Fixed-self.MovingWarped);
                denominator =  (self.FgradMagSquared + FixedMinusMovingWarped.^2);
                
                % Compute additional displacement field - Thirion
                directionallyConstFactor = FixedMinusMovingWarped ./ denominator;
                Du_x = directionallyConstFactor .* self.FgradX;
                Du_y = directionallyConstFactor .* self.FgradY;
                Du_z = directionallyConstFactor .* self.FgradZ;

                zeroUpdateLocations = (abs(FixedMinusMovingWarped) < self.IntensityDifferenceThreshold) |...
                    (denominator < self.DenominatorThreshold) |...
                    isnan(self.MovingWarped);
                
                Du_x(zeroUpdateLocations) = 0;
                Du_y(zeroUpdateLocations) = 0;
                Du_z(zeroUpdateLocations) = 0;
                
                % Compute total displacement vector - additive update
                self.Da_x = self.Da_x + Du_x;
                self.Da_y = self.Da_y + Du_y;
                self.Da_z = self.Da_z + Du_z;
                
                % Regularize vector field by gaussian smoothing.
                self.Da_x = filter3DWithSeparableKernel(self.Da_x, self.hGaussian);
                self.Da_y = filter3DWithSeparableKernel(self.Da_y, self.hGaussian);
                self.Da_z = filter3DWithSeparableKernel(self.Da_z, self.hGaussian);
                
            end
            
        end
                   
    end
    
    
end

function out = filter3DWithSeparableKernel(I,hgaussian)

% convn only uses zero padding style of boundary behavior. To get
% 'replicate' boundary behavior, pad edges with replicated values and then
% use the 'valid' option. This will result in an output of the same size as
% the input volume.
kernelHalfWidth = (length(hgaussian)-1)/2;
I = padarray(I,kernelHalfWidth.*[1 1 1],'replicate');
out = convn(I,hgaussian,'valid');
out = convn(out,hgaussian','valid');
out = convn(out,reshape(hgaussian,1,1,length(hgaussian)),'valid');

end

