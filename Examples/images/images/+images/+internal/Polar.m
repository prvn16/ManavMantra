%   FOR INTERNAL USE ONLY -- This class is intentionally
%   undocumented and is intended for use only within other toolbox
%   classes and functions. Its behavior may change, or the feature
%   itself may be removed in a future release.
%
%LogPolar Log-polar image resampler.
%
%   A Polar object encapsulates the polar resampled image grid and
%   the spatial referencing information used to create the polar image
%   grid. This object can be used to obtain rho,theta locations given
%   intrinsic row,col locations, or to obtain row,col locations given
%   rho,theta locations.

% Copyright 2013 The MathWorks, Inc.


classdef Polar
    
    properties (SetAccess = 'private')
        
        rhoMin
        rhoMax
        
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
        
        function self = Polar(I,thetaRange)
            
            inSize = size(I);
                                    
            self.thetaMin = thetaRange(1);
            self.thetaMax = thetaRange(2);
                        
            center = 0.5 + inSize/2;
            cx = center(2);
            cy = center(1);
                        
            self.rhoMin = 0;
            self.rhoMax = hypot(cx-0.5,cy-0.5);
            self.numSamplesRho = round(self.rhoMax);
            rho = linspace(self.rhoMin,self.rhoMax,self.numSamplesRho);
            
            self.numSamplesTheta = self.numSamplesRho;
            deltaTheta = self.thetaMax / self.numSamplesTheta;
            theta = linspace(0,self.thetaMax-deltaTheta,self.numSamplesTheta);
            
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
        
        function [thetaIntrinsic,rhoIntrinsic] = worldToIntrinsic(self,thetaWorld,rhoWorld)
            %worldToIntrinsic Convert from world coordinates to intrinsic
            %coordinates in the theta,rho grid.
            %
            % [thetaIntrinsic,rhoIntrinsic] = worldToIntrinsic(R,theta,rho)
            %   maps point locations from theta,rho locations to intrinsic
            %   coordinates in the polar grid.
            
           thetaIntrinsic = 1 + thetaWorld * self.numSamplesTheta /  self.thetaMax; 
           rhoIntrinsic = 1 + rhoWorld * self.numSamplesRho / self.rhoMax; 
            
        end
        
        function [thetaWorld,rhoWorld] = intrinsicToWorld(self,thetaIntrinsic,rhoIntrinsic)
            %intrinsicToWorld Convert from intrinsic coordinates in the
            %theta,logRho grid to theta,rho locations.
            %
            % [theta, rho] = intrinsicToWorld(R,thetaIntrinsic,logRhoIntrinsic);
            %   maps point locations from intrinsic coordinates in the
            %   log-polar grid to the corresponding theta,rho locations.
             
           thetaWorld = (thetaIntrinsic-1) .* self.thetaMax ./ self.numSamplesTheta;
           rhoWorld   = (rhoIntrinsic - 1) .* self. rhoMax ./ self.numSamplesRho;
                        
        end
        
        
    end
    
end


