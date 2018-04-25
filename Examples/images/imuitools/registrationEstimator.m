function registrationEstimator(varargin)
%registrationEstimator Register 2D grayscale images.
%   registrationEstimator opens an Image Registration app. The app can be used
%   to perform intensity-based, feature-based, and nonrigid image
%   registration.
%
%   registrationEstimator(MOVING,FIXED) loads the grayscale images MOVING and
%   FIXED into an Image Registration app.
%
%   registrationEstimator CLOSE closes all open Registration Estimator apps.
%
%   Class Support
%   -------------
%   FIXED and MOVING are images of class uint8, int16, uint16, single,
%   double, or logical.
%
%   See also imregister, imregtform, imregconfig, imregdemons, imwarp.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(0,2);

varargin = matlab.images.internal.stringToChar(varargin);

switch nargin
    case 0
        % Create a new Registration Estimator app.
        images.internal.app.registration.ImageRegistration();
    case 1
        if ischar(varargin{1})
            % Handle the 'close' request
            validatestring(varargin{1}, {'close'}, mfilename);
            images.internal.app.registration.ImageRegistration.deleteAllTools();
        else
            error(message('images:imageRegistration:expectedTwoImages'));
        end
    case 2
        moving = varargin{1};
        fixed = varargin{2};
        supportedImageClasses    = {'uint8','int16','uint16','single','double','logical'};
        supportedImageAttributes = {'real','nonsparse','nonempty'};
        validateattributes(fixed,supportedImageClasses,supportedImageAttributes,mfilename,'FIXED');
        validateattributes(moving,supportedImageClasses,supportedImageAttributes,mfilename,'MOVING');
        
        % If fixed image is RGB, issue warning and convert to grayscale.
        isFixedRGB = ndims(fixed)==3 && size(fixed,3)==3;
        
        % If image is not 2D grayscale or RGB, error.    
        if ~isFixedRGB && ~ismatrix(fixed)
            error(message('images:imageRegistration:expectedGray','FIXED'));
        end
        
        % If moving image is RGB, issue warning and convert to grayscale.
        isMovingRGB = ndims(moving)==3 && size(moving,3)==3;

        % If image is not 2D grayscale or RGB, error.    
        if ~isMovingRGB && ~ismatrix(moving)
            error(message('images:imageRegistration:expectedGray','MOVING'));
        end
        
        % Images must be at least 16x16 in dimension
        validSize = size(fixed,1) >= 16 && size(fixed,2) >= 16;
        if ~validSize
            error(message('images:imageRegistration:expected16x16','FIXED'));
        end

        validSize = size(moving,1) >= 16 && size(moving,2) >= 16;
        if ~validSize
            error(message('images:imageRegistration:expected16x16','MOVING'));
        end
        
        % Create a new Registration Estimator app.
        images.internal.app.registration.ImageRegistration(moving,fixed,inputname(1),inputname(2)); 
end
        
end
