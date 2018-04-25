classdef MultiResolutionDemons3D < images.registration.internal.Demons3D
    
    %   Copyright 2014-2015 The MathWorks, Inc.
    
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
        
        function self = downsampleMovingAndFixedToPyramidLevel(self,PyramidLevel)
            
            self.Moving = antialiasResize(self.MovingFullResolution,0.5.^(self.PyramidLevels-PyramidLevel));
            self.Fixed  = antialiasResize(self.FixedFullResolution,0.5.^(self.PyramidLevels-PyramidLevel));
            
        end
        
        function self = resampleAccumulatedFieldByScaleFactor(self,relativeScaleChange)
            % Upsample displacement field as we move from lower resolution
            % to higher resolution sections of the pyramid.
            
            % Adjust accumulated displacement field. First resize to
            % account for relative scale change between pyramid levels.
            self.Da_x = antialiasResize(self.Da_x,relativeScaleChange);
            self.Da_y = antialiasResize(self.Da_y,relativeScaleChange);
            self.Da_z = antialiasResize(self.Da_z,relativeScaleChange);
            
            % Now adjust for relative scale difference in displacement
            % magnitudes
            self.Da_x = self.Da_x .* relativeScaleChange;
            self.Da_y = self.Da_y .* relativeScaleChange;
            self.Da_z = self.Da_z .* relativeScaleChange;
            
        end
        
    end
    
    methods
        
        function self = moveToPyramidLevel(self,pyramidLevel)
            
            self = self.downsampleMovingAndFixedToPyramidLevel(pyramidLevel);
            if pyramidLevel > 1
                self = self.resampleAccumulatedFieldByScaleFactor(2);
            end
            
        end
        
        function Dout = get.D(self)
            
            paddedSize = size(self.Da_x);
            originalFixedSize = paddedSize-self.FixedPadVec;
            Dout = zeros(originalFixedSize);
            m = 1:originalFixedSize(1);
            n = 1:originalFixedSize(2);
            p = 1:originalFixedSize(3);
            Dout(:,:,:,1) = self.Da_x(m,n,p);
            Dout(:,:,:,2) = self.Da_y(m,n,p);
            Dout(:,:,:,3) = self.Da_z(m,n,p);
            
        end
        
        function self = MultiResolutionDemons3D(moving,fixed,sigma,pyramidLevels)
            
            self = self@images.registration.internal.Demons3D(moving,fixed,sigma);
            
            [fixed,self.FixedPadVec] = images.registration.internal.padForPyramiding(fixed,pyramidLevels);
            moving = images.registration.internal.padForPyramiding(moving,pyramidLevels);
            [self.Da_x] = images.registration.internal.padForPyramiding(self.Da_x,pyramidLevels);
            [self.Da_y] = images.registration.internal.padForPyramiding(self.Da_y,pyramidLevels);
            [self.Da_z] = images.registration.internal.padForPyramiding(self.Da_z,pyramidLevels);
            
            self.MovingFullResolution = double(moving);
            self.FixedFullResolution  = double(fixed);
            
            self.PyramidLevels = pyramidLevels;

            % Downsample the initial condition for Da_x and Da_y to the
            % resolution of the lowest resolution section of the pyramid
            self = self.resampleAccumulatedFieldByScaleFactor(0.5^(pyramidLevels-1));
            
        end
        
    end
    
end

function out = antialiasResize(in,factor,varargin)

% Implement a volumetric resize function that applies a second order
% low-pass butterworth filter to the input image. The cutoff of the filter
% is chosen based on the resize scale factor to limit aliasing effects.

classIn = class(in);

if factor == 1
    out = in;
    return;
end

if factor < 1
    
    % Move to Frequency domain.
    I = fftshift(fftn(in));
    
    % Construct low-pass filter with cutoff based on scale factor.
    H = butterwth(0.5*factor,2,size(in));
    
    % Obtain low-pass filtered version of input spatial domain volume
    in = ifftn(ifftshift(I.*H),'symmetric');
    
end

% Apply scale transform of input volume
scaleTransform = affine3d([factor 0 0 0; 0 factor 0 0; 0 0 factor 0; 0 0 0 1]);

out = imwarp(in,scaleTransform,'linear','SmoothEdges', true);

out = cast(out,classIn);

end


function H = butterwth(Do,n,outsize)

numRows = outsize(1);
numCols = outsize(2);
numPlanes = outsize(3);

% Define normalized frequency mesh grid
u = images.internal.createNormalizedFrequencyVector(numCols);
v = images.internal.createNormalizedFrequencyVector(numRows);
w = images.internal.createNormalizedFrequencyVector(numPlanes);
[U,V,W] = meshgrid(u,v,w);

D = sqrt(U.^2+V.^2+W.^2);

H = 1 ./ (1 + (D./Do).^(2*n));

end


