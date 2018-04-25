function [Gmag, Gazimuth, Gelevation] = imgradient3(varargin)%#codegen
%IMGRADIENT3 Find the 3-D gradient magnitude and direction of an image.
%
% Copyright 2015 The MathWorks, Inc. 

narginchk(1,3);

defaultMethod = 'sobel';

if (nargin == 1)
    I = varargin{1};
    validateattributes(I,{'numeric','logical'},{'3d','nonsparse','real'}, ...
                       mfilename,'I',1);
                   
    % Error out if input image is scalar or 2D
    coder.internal.errorIf(numel(size(I)) < 3,...
        'images:validate:tooFewDimensions', 'I', 3); 
    
    method = defaultMethod;
    
    % Gx, Gy and Gz are not given, use IMGRADIENTXYZ to compute Gx, Gy
    % and Gz.
    [Gx, Gy, Gz] = imgradientxyz(I,method);

else % (nargin == 2)
    if ischar(varargin{2})
        I = varargin{1};
        validateattributes(I,{'numeric','logical'},{'3d','nonsparse', ...
                           'real'},mfilename,'I',1);
         methodstrings = {'sobel','prewitt','central', ...
            'intermediate'};
        method = validatestring(varargin{2}, methodstrings, ...
            mfilename, 'Method', 2);
        
        % Gx, Gy and Gz are not given, use IMGRADIENTXYZ to compute Gx, Gy
        % and Gz.
        [Gx, Gy, Gz] = imgradientxyz(I,method);
    
    else
        GxIn = varargin{1};
        GyIn = varargin{2}; 
        GzIn = varargin{3};

        validateattributes(GxIn,{'numeric','logical'},{'3d','nonsparse', ...
                           'real'},mfilename,'Gx',1);
        validateattributes(GyIn,{'numeric','logical'},{'3d','nonsparse', ...
                           'real'},mfilename,'Gy',2);

        validateattributes(GzIn,{'numeric','logical'},{'3d','nonsparse', ...
                           'real'},mfilename,'Gz',3);

       coder.internal.errorIf(~isequal(size(GxIn),size(GyIn),size(GzIn)),...
             'images:validate:unequalSizeMatrices3', 'Gx', 'Gy', 'Gz');
         
        coder.internal.errorIf(~isequal(class(GxIn),class(GyIn),class(GzIn)),...
             'images:validate:differentClassMatrices3', 'Gx', 'Gy', 'Gz');
        
        if isa(GxIn,'single')
           classToCast = 'single';
        else
            classToCast = 'double';
        end

        Gx = cast(GxIn, classToCast);


        if isa(GyIn,'single')
           classToCast = 'single';
        else
            classToCast = 'double';
        end

        Gy = cast(GyIn, classToCast);

        if isa(GzIn,'single')
           classToCast = 'single';
        else
            classToCast = 'double';
        end

        Gz = cast(GzIn, classToCast);
    end

end


% Compute gradient magnitude
Gmag = sqrt(Gx.^2 + Gy.^2 + Gz.^2);

% Compute gradient direction
if (nargout > 1)
       
    Gazimuth = atan2(-Gy,Gx)*180/pi; % Radians to degrees
    
    Gelevation = atan2(Gz, hypot(Gx, Gy))*180/pi; 
    
end

end
