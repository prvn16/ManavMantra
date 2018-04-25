%   FOR INTERNAL USE ONLY -- This class is intentionally
%   undocumented and is intended for use only within other toolbox
%   classes and functions. Its behavior may change, or the feature
%   itself may be removed in a future release.
%
%LogPolar Log-polar image resampler.
%
%   A LogPolar object encapsulates the log-polar resampled image grid and
%   the spatial referencing information used to create the log-polar image
%   grid. This object can be used to obtain rho,theta locations given
%   intrinsic row,col locations, or to obtain row,col locations given
%   rho,theta locations.

% Copyright 2013 The MathWorks, Inc.


classdef LogPolar
    
    properties (SetAccess = 'private')
        
        logRhoMin
        logRhoMax
        
        thetaMin
        thetaMax
        
        numSamplesRho
        numSamplesTheta
                
    end
    
    properties
        
        % In the current architecture of imregcorr, this needs to be
        % writeable so that windowing can be applied prior to taking FFT.
        resampledImage
        
    end
    
    
    methods
        
        function self = LogPolar(I,thetaRange)
            
            inSize = size(I);
            
            % Set the maximum radius to be the largest hypotenuse. When
            % computing the polar FFT, we don't want to throw away
            % information at the high frequency regions of the FFT.
            center = 0.5 + inSize/2;
            cx = center(2);
            cy = center(1);
            
            rhoMin = 1;
            rhoMax = hypot(cx-0.5,cy-0.5);
            % Allow numerics to degenerate reasonably if grid size is 1
            % pixel along a particular dimension.
            rhoMax = max(1+eps,rhoMax);

            self.numSamplesRho = round(rhoMax);
            
            self.thetaMin = thetaRange(1);
            self.thetaMax = thetaRange(2);
            
            % The following equation describes the constraining
            % relationship necesssary to guarantee that a pixel's nearest
            % neighbors in orthogonal directions are equally spaced:
            %
            % rhoMin = rhoMax * exp(-2*pi*(numSamplesRho-1) / numSamplesTheta );
            %
            % Which can be rearranged to calculate the number of angular
            % samples necessary to achieve equally spaced orthogonal
            % neighbors given rhoMin,rhoMax, and numSamplesRho: 
            self.numSamplesTheta = -2*pi * (self.numSamplesRho-1) / log(rhoMin/rhoMax);
             
            % Allow numerics to degenerate reasonably if grid size is 1
            % pixel along a particular dimension.
            self.numSamplesTheta = max(1,self.numSamplesTheta);
            
            deltaTheta = self.thetaMax / self.numSamplesTheta;
            theta = linspace(0,self.thetaMax-deltaTheta,self.numSamplesTheta);
            
            % We sample rho such that the maximum logRho is log(rhoMax) and
            % the minimum value of logRho is 1. We sample linearly in
            % log-rho. It can be proven that this type of scaling is
            % equivalent to an exponential of base rhoMax:
            %
            %    k = 1:numSamplesRho;
            %    rhoBaseN = rhoMax .^ ( k ./ numSamplesRho);  
            %
            % That is, our spacing in rho is independent of the choice of log
            % base.
            
            self.logRhoMin = log(rhoMin);
            self.logRhoMax = max(1e-6,log(rhoMax));
            logRho = linspace(self.logRhoMin,self.logRhoMax,self.numSamplesRho);
            rho   = exp(logRho);
            
            % Build mesh of rho, theta
            [theta,rho] = meshgrid(theta,rho);
            
            % Find cooresponding intrinsic coordinates in input image
            [X,Y] = pol2cart(theta,rho);
            
            % Adjust X and Y to account for center of polar transformation
            X = X+cx;
            Y = Y+cy;
            
            % Resample and maintain the resampled image grid in single
            % precision floating point for speed unless supplied data was
            % in double.
            if ~isa(I,'double')
                I = single(I);
            end
            
            self.resampledImage = images.internal.interp2d(I,X,Y,'bilinear',0);
            
        end
        

        function [thetaIntrinsic,logRhoIntrinsic] = worldToIntrinsic(self,thetaWorld,rhoWorld)
            %worldToIntrinsic Convert from world coordinates to intrinsic
            %coordinates in the theta,logRho grid.
            %
            % [thetaIntrinsic,logRhoIntrinsic] = worldToIntrinsic(R,theta,rho)
            %   maps point locations from theta,rho locations to intrinsic
            %   coordinates in the log-polar grid.
            
           thetaIntrinsic  = 1 + thetaWorld * self.numSamplesTheta /  self.thetaMax; 
           logRhoIntrinsic = 1 + log(rhoWorld) * self.numSamplesRho / self.logRhoMax; 
            
        end
        
        function [thetaWorld,rhoWorld] = intrinsicToWorld(self,thetaIntrinsic,logRhoIntrinsic)
            %intrinsicToWorld Convert from intrinsic coordinates in the
            %theta,logRho grid to theta,rho locations.
            %
            % [theta, rho] = intrinsicToWorld(R,thetaIntrinsic,logRhoIntrinsic);
            %   maps point locations from intrinsic coordinates in the
            %   log-polar grid to the corresponding theta,rho locations.
             
           thetaWorld = (thetaIntrinsic-1) .* self.thetaMax ./ self.numSamplesTheta;
           
           deltaLogRho = self.logRhoMax ./ self.numSamplesRho;
           rhoWorld = exp((logRhoIntrinsic-1) .* deltaLogRho);
             
        end
        
        
    end
    
end


