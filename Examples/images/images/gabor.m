%gabor Create a Gabor filter.
%
%   A gabor object encapsulates the full parameterization of a Gabor filter
%   and defines quantities of interest when working with Gabor filters. The
%   gabor class can be used to easily define arrays of gabor objects that
%   represent Gabor filter banks.
%
%   gabor properties (SetAccess = private):
%      Orientation - Orientation (in degrees)
%      Wavelength  - Wavelength of sinusoid (in pixels/cycle)
%      SpatialAspectRatio - Aspect ratio of gaussian in spatial domain
%      SpatialFrequencyBandwidth - Spatial frequency bandwidth (in octaves)
%      SpatialKernel - Complex spatial convolution kernel
%
%   g = gabor(WAVELENGTH,ORIENTATION) creates a gabor filter array with the
%   specified wavelength(s) (in pixels/cycle) and orientation(s) (in
%   degrees). WAVELENGTH describes the wavelength of the sinusoidal
%   carrier. Valid values for WAVELENGTH are in the range [2, Inf).
%   ORIENTATION is the orientation of the filter, where the orientation is
%   defined as the normal direction to the sinusoidal plane wave. Valid
%   values for ORIENTATON are in the range [0 360]. When WAVELENGTH or
%   ORIENTATION are vectors, g is an array of gabor objects that contains
%   all unique combinations of WAVELENGTH and ORIENTATION. For example, if
%   WAVELENGTH is a vector of length 2 and ORIENTATION is a vector of
%   length 3, then the output gabor array will be a vector of length 6.
%
%   g = gabor(___,Name,Value,___) creates a gabor filter array using
%   name-value pairs to control aspects of gabor filter design. Each value
%   may be specified as a vector, in which case the output gabor filter
%   array g will contain all unique combinations of the input values.
%
%   Parameters include:
%
%     'SpatialFrequencyBandwidth' -   A numeric vector that defines the
%                                     spatial-frequency bandwidth in units
%                                     of octaves. The spatial-frequency
%                                     bandwidth determines the cutoff of
%                                     the filter response as frequency
%                                     content in the input image varies
%                                     from the preferred frequency,
%                                     1/WAVELENGTH. Typical values for
%                                     spatial-frequency bandwidth are in
%                                     the range [0.5 2.5].
%  
%                                     Default value: 1.0.
%  
%     'SpatialAspectRatio' -          A numeric vector that defines the ratio 
%                                     of the semi-major and semi-minor axes
%                                     of the gaussian envelope:
%                                     semi-minor/semi-major. This parameter
%                                     controls the ellipticity of the
%                                     gaussian envelope. Typical values for
%                                     spatial aspect ratio are in the range
%                                     [0.23 0.92].
%  
%                                     Default value: 0.5.
%
%   Notes
%   -----
%   The range of ORIENTATION is [0 360] degrees because this class defines
%   a complex gabor filter in the spatial domain which is not conjugate
%   symmetric in the frequency domain. If you are only interested in Gabor
%   magnitude response, the range of ORIENTATION can be restricted to [0
%   180] degrees.
%
%   Example 1
%   ---------
%   This example applies a gabor filter bank of 3 orientations and 2
%   different wavelengths to an input image. The magnitude response is
%   shown for each filter. 
%
%   I = imread('cameraman.tif');
%   gaborBank = gabor([4 8],[0 90]);
%   gaborMag = imgaborfilt(I,gaborBank);
%   figure
%   subplot(2,2,1);
%   for p = 1:4
%       subplot(2,2,p)
%       imshow(gaborMag(:,:,p),[]);
%       theta = gaborBank(p).Orientation;
%       lambda = gaborBank(p).Wavelength;
%       title(sprintf('Orientation=%d, Wavelength=%d',theta,lambda));
%   end
%
%   Example 2
%   ---------
%   % Construct a gabor filter array and visualize the real part and
%   % of the spatial convolution kernel of each gabor filter in the
%   % array.
%
%   g = gabor([5 10],[0 90]);
%   figure;
%   subplot(2,2,1)
%   for p = 1:length(g)
%       subplot(2,2,p);
%       imshow(real(g(p).SpatialKernel),[]);
%       lambda = g(p).Wavelength;
%       theta  = g(p).Orientation;
%       title(sprintf('Re[h(x,y)], \\lambda = %d, \\theta = %d',lambda,theta));
%   end
%   
%   See also imgaborfilt

% Copyright 2015-2017 The MathWorks, Inc.

classdef gabor
    
    properties (SetAccess = immutable)
        
        Wavelength
        Orientation
        SpatialAspectRatio
        SpatialFrequencyBandwidth
        
    end
    
    properties (Dependent=true, Hidden=true)
       KernelSize 
    end
    
    % The SpatialKernel is only computed as needed
    properties (Dependent)
        SpatialKernel
    end
    
    properties(Access=private, Dependent=true)
        SigmaX
        SigmaY
        Rx
        Ry
    end

    methods
        
        function self = gabor(varargin)
            varargin = matlab.images.internal.stringToChar(varargin);
            
            if (nargin > 0)
                results = parseInputs(varargin{:});
                results = computeParameterCombinations(results);
                numFilters = length(results.Orientation);
                % Use default construct to allocate vector of gabor filter
                % instances.
                self(numFilters) = gabor(); %#ok<*EMVDF>
                for n = 1:numFilters
                   self(n).Wavelength = results.Wavelength(n);
                   self(n).Orientation = results.Orientation(n);
                   self(n).SpatialAspectRatio = results.SpatialAspectRatio(n);
                   self(n).SpatialFrequencyBandwidth = results.SpatialFrequencyBandwidth(n);
                end
                
            else
                % Default constructor
                self.Wavelength = 4;
                self.Orientation = 0;
                self.SpatialAspectRatio = 0.5;
                self.SpatialFrequencyBandwidth = 1.0;
            end
            
        end
        
        function sigmaX = get.SigmaX(self)
            % From relationship in "Nonlinear Operator in Oriented Texture", Kruizinga,
            % Petkov, 1999.
            BW = self.SpatialFrequencyBandwidth;
            sigmaX = self.Wavelength/pi*sqrt(log(2)/2)*(2^BW+1)/(2^BW-1);
        end
        
        function sigmaY = get.SigmaY(self)            
            sigmaY = self.SigmaX ./ self.SpatialAspectRatio;
        end
        
        function rx = get.Rx(self)
            % SpatialKernel needs large (7 sigma radial) falloff of
            % Gaussian in spatial domain for frequency domain and spatial
            % domain computations to be equivalent within floating point
            % round off error.
            rx = ceil(7*self.SigmaX);
        end
        
        function ry = get.Ry(self)
            ry = ceil(7*self.SigmaY);
        end
        
        function kSize = get.KernelSize(self)
            r = max(self.Rx,self.Ry);
            kSize = [2*r+1,2*r+1];
        end
        
        function h = get.SpatialKernel(self)
            
            % Parameterization of spatial kernel frequency includes Phi as
            % an independent variable. We use a constant of 0.
            phi = 0;
            
            sigmax = self.SigmaX;
            sigmay = self.SigmaY;
            
            r = max(self.Rx,self.Ry);
            
            [X,Y] = meshgrid(-r:r,-r:r);
            
            Xprime = X .*cosd(self.Orientation) - Y .*sind(self.Orientation);
            Yprime = X .*sind(self.Orientation) + Y .*cosd(self.Orientation);
            
            hGaussian = exp( -1/2*( Xprime.^2 ./ sigmax^2 + Yprime.^2 ./ sigmay^2));
            hGaborEven = hGaussian.*cos(2*pi.*Xprime ./ self.Wavelength+phi);
            hGaborOdd  = hGaussian.*sin(2*pi.*Xprime ./ self.Wavelength+phi);
            
            h = complex(hGaborEven,hGaborOdd);
            
        end
        
    end
    
    methods (Hidden = true)
        
        function H = makeFrequencyDomainTransferFunction(self,imageSize,classA)
           
            % Directly construct frequency domain transfer function of
            % Gabor filter. (Jain, Farrokhnia, "Unsupervised Texture
            % Segmentation Using Gabor Filters", 1999)
            M = imageSize(1);
            N = imageSize(2);
            u = cast(images.internal.createNormalizedFrequencyVector(N),classA);
            v = cast(images.internal.createNormalizedFrequencyVector(M),classA);
            [U,V] = meshgrid(u,v);
           
            Uprime = U .*cosd(self.Orientation) - V .*sind(self.Orientation);
            Vprime = U .*sind(self.Orientation) + V .*cosd(self.Orientation);
                        
            sigmau = 1/(2*pi*self.SigmaX);
            sigmav = 1/(2*pi*self.SigmaY);
            freq = 1/self.Wavelength;
            
            A = 2*pi*self.SigmaX*self.SigmaY;
            
            H = A.*exp(-0.5*( ((Uprime-freq).^2)./sigmau^2 + Vprime.^2 ./ sigmav^2) );
             
        end
        
    end
    
end


function resultsOut = parseInputs(varargin)

narginchk(2,inf);

results = struct('Wavelength',0,'Orientation',0,'SpatialFrequencyBandwidth',1.0,'SpatialAspectRatio',0.5);

wavelength = varargin{1};
validateattributes(wavelength,{'numeric'},{'vector','nonempty','real','positive','finite','nonsparse','>=',2},...
    mfilename,'Wavelength');
results.Wavelength = double(wavelength);

orientation = varargin{2};
validateattributes(orientation,{'numeric'},{'vector','nonempty','real','finite','nonsparse'},...
    mfilename,'Theta');
results.Orientation = double(orientation);

param_strings = {'SpatialAspectRatio','SpatialFrequencyBandwidth'}; %#ok<*EMCA>

for n = 3 : 2 : length(varargin)
    % Error if param is not a string.
    if ~(ischar(varargin{n}) || isstring(varargin{n}) && isscalar(varargin{n}))
        error(message('images:validate:mustBeString'));
    else
        param = validatestring(varargin{n},param_strings,mfilename);
        
        % Error if corresponding value is missing.
        if n+1>length(varargin)
            error(message('images:validate:missingValue',param));
        end
        
        switch param
            case 'SpatialFrequencyBandwidth'
                bandwidth = varargin{n+1};
                
                validateattributes(bandwidth,{'numeric'},{'vector','nonempty','real','positive','finite','nonsparse'},...
                    mfilename,'SpatialFrequencyBandwidth');
                
                results.SpatialFrequencyBandwidth = double(bandwidth);
                
            case 'SpatialAspectRatio'
                aspectRatio = varargin{n+1};
                
                validateattributes(aspectRatio,{'numeric'},{'vector','nonempty','real','positive','finite','nonsparse'},...
                    mfilename,'SpatialAspectRatio');
                
                results.SpatialAspectRatio = double(aspectRatio);
                
            otherwise
                assert(false,'Unexpected Name/Value pair provided to gabor.');
        end
    end
end

% Silently filter non-unique entries in parameter vectors down to unique
% elements.
resultsOut = structfun(@unique,results,'UniformOutput',false);

end

function resultsOut = computeParameterCombinations(results)

[lambda,theta,bandwidth,spatialAspectRatio] = ...
    ndgrid(results.Wavelength,results.Orientation,...
    results.SpatialFrequencyBandwidth,results.SpatialAspectRatio);

resultsOut = struct('Wavelength',lambda(:),...
                'Orientation',theta(:),...
                'SpatialFrequencyBandwidth',bandwidth(:),...
                'SpatialAspectRatio',spatialAspectRatio(:));

end
