classdef MultiResolutionDemons2D < images.registration.internal.Demons2D
    
    %   Copyright 2014 The MathWorks, Inc.
    
    properties
        
        PyramidLevels
        MovingFullResolution
        FixedFullResolution
        FixedPadVec
        
    end
    
    properties (Dependent)
        
        D
        
    end
    
    methods (Access = private)
        
        function self = resampleAccumulatedFieldByScaleFactor(self,relativeScaleChange)
            
            self.Da_x = imresize(self.Da_x,relativeScaleChange,'bilinear');
            self.Da_y = imresize(self.Da_y,relativeScaleChange,'bilinear');
            
            % Now adjust for relative scale difference in displacement
            % magnitudes
            self.Da_x = self.Da_x .* relativeScaleChange;
            self.Da_y = self.Da_y .* relativeScaleChange;
            
        end
        
        function self = downsampleMovingAndFixedToPyramidLevel(self,PyramidLevel)
            
            if PyramidLevel == self.PyramidLevels
                % Performance Optimization. Imresize by a scale factor of 1
                % still performs a full remap and resampling operation.
                self.Moving = self.MovingFullResolution;
                self.Fixed  = self.FixedFullResolution;
            else
                self.Moving = imresize(self.MovingFullResolution,0.5.^(self.PyramidLevels-PyramidLevel));
                self.Fixed  = imresize(self.FixedFullResolution,0.5.^(self.PyramidLevels-PyramidLevel));
            end
            
        end
        
        
    end
    
    methods
         
        function Dout = get.D(self)
            % Remove pixels from D that are an artifact of padding prior to
            % pyramiding. Combine Da_x and Da_y into a single array.
            
            paddedSize = size(self.Da_x);
            originalFixedSize = paddedSize-self.FixedPadVec;
            m = 1:originalFixedSize(1);
            n = 1:originalFixedSize(2);
            Dout = cat(3,self.Da_x(m,n), self.Da_y(m,n));
            
        end
        
        function self = MultiResolutionDemons2D(moving,fixed,sigma,pyramidLevels)
            
            self = self@images.registration.internal.Demons2D(moving,fixed,sigma);
            
            [fixed,self.FixedPadVec]   = images.registration.internal.padForPyramiding(fixed,pyramidLevels);
            moving = images.registration.internal.padForPyramiding(moving,pyramidLevels);
            self.Da_x = images.registration.internal.padForPyramiding(self.Da_x,pyramidLevels);
            self.Da_y = images.registration.internal.padForPyramiding(self.Da_y,pyramidLevels);
            
            self.MovingFullResolution = double(moving);
            self.FixedFullResolution  = double(fixed);
            
            self.PyramidLevels = pyramidLevels;
            
            % Downsample the initial condition for Da_x and Da_y to the
            % resolution of the lowest resolution section of the pyramid
            self = self.resampleAccumulatedFieldByScaleFactor(0.5^(pyramidLevels-1));
            
        end
        
        function self = moveToPyramidLevel(self,pyramidLevel)
            
            self = self.downsampleMovingAndFixedToPyramidLevel(pyramidLevel);
            if pyramidLevel > 1
                self = self.resampleAccumulatedFieldByScaleFactor(2);
            end
            
        end
                
    end
    
end
