function u = im2uint8(img, varargin)
%IM2UINT8 Convert gpuArray image to 8-bit unsigned integers.
%   IM2UINT8 takes a gpuArray image as input, and returns a gpuArray image
%   of underying class uint8.  If the input gpuArray is of class uint8, the
%   output gpuArray is identical to it.  If the input gpuArray is not
%   uint8, IM2UINT8 returns the equivalent gpuArray of underlying class
%   uint8, rescaling or offsetting the data as necessary.
%
%   I2 = IM2UINT8(I1) converts the intensity gpuArray image I1 to uint8,
%   rescaling the data if necessary.
%
%   RGB2 = IM2UINT8(RGB1) converts the truecolor gpuArray image RGB1 to
%   uint8, rescaling the data if necessary.
%
%   I = IM2UINT8(BW) converts the binary gpuArray image BW to a uint8
%   intensity image, changing one-valued elements to 255.
%
%   X2 = IM2UINT8(X1,'indexed') converts the indexed gpuArray image X1 to
%   uint8, offsetting the data if necessary. Note that it is not always
%   possible to convert an indexed gpuArray image to uint8. If X1 is
%   double, then the maximum value of X1 must be 256 or less.  If X1 is
%   uint16, the maximum value of X1 must be 255 or less.
%
%   Class Support
%   -------------
%   Intensity and truecolor gpuArray images can be uint8, uint16, double,
%   logical, single, or int16. Indexed gpuArray images can be uint8,
%   uint16, double or logical. Binary input gpuArray images must be
%   logical. The output gpuArray is uint8.
%
%   Example
%   -------
%       I1 = gpuArray(reshape(uint16(linspace(0,65535,25)),[5 5]))
%       I2 = im2uint8(I1)
%
%   See also GPUARRAY/IM2DOUBLE, GPUARRAY/IM2INT16, GPUARRAY/IM2SINGLE,
%            GPUARRAY/IM2UINT16, GPUARRAY/UINT8, GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.

%% inputs
narginchk(1,2);

classImg = classUnderlying(img);
hValidateAttributes(img,...
    {'double','logical','uint8','uint16','single','int16'}, ...
    {'nonsparse'},mfilename,'Image',1);

if(~isreal(img))
    warning(message('images:im2uint8:ignoringImaginaryPartOfInput'));
    img = real(img);
end

if nargin == 2
    validatestring(varargin{1},{'indexed'},mfilename,'type',2);
end

%% process
if strcmp(classImg, 'uint8')
    u = img;
    
elseif strcmp(classImg, 'logical')
    u = uint8(img) * 255;
    
else %double, single, uint16, or int16
    if nargin == 1
        if strcmp(classImg, 'int16')
            z = uint16(int32(img) + 32768);
            u = uint8(double(z)*1/257);
        end
        
        % intensity image
        if strcmp(classImg, 'double')
            u = arrayfun(@grayto8double,img);
        elseif strcmp(classImg, 'single')
            u = arrayfun(@grayto8single,img);
        elseif strcmp(classImg, 'uint16')
            u = arrayfun(@grayto8uint8,img);
        end
        
    else
        s.type = '()';
        s.subs = {':'};
        
        if strcmp(classImg, 'int16')
            error(message('images:im2uint8:invalidIndexedImage'))
            
        elseif strcmp(classImg, 'uint16')
            if (max(subsref(img,s)) > 255)
                error(message('images:im2uint8:tooManyColorsFor8bitStorage'))
            else
                u = uint8(img);
            end
            
        else %double or single
            
            if any(max(subsref(img,s)) >= 257)
                error(message('images:im2uint8:tooManyColorsFor8bitStorage'))
            elseif any(min(subsref(img,s)) < 1)
                error(message('images:im2uint8:invalidIndexValue'))
            else
                u = uint8(img-1);
            end
        end
    end
end


function b = grayto8double(img)
%GRAYTO8 Scale and convert grayscale image to uint8.
%   B = GRAYTO8(A) converts the double array A to uint8 by
%   scaling A by 255 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 255;
%   values less than 0.0 are converted to 0.

if isnan(img)
    b = uint8(0);
else
    % uint8() rounds DOUBLE and SINGLE values. No need to add 0.5 as in
    % grayto8 MEX code
    img = img * 255;
    if img > 255
        img = 255;
    elseif img < 0
        img = 0;
    end
    b = uint8(img);
    
end

function b = grayto8single(img)
%GRAYTO8 Scale and convert grayscale image to uint8.
%   B = GRAYTO8(A) converts the double array A to uint8 by
%   scaling A by 255 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 255;
%   values less than 0.0 are converted to 0.

if isnan(img)
    b = uint8(0);
else
    % uint8() rounds DOUBLE and SINGLE values. No need to add 0.5 as in
    % grayto8 MEX code
    maxVal = single(255);
    minVal = single(0);
    img = img * maxVal;
    if img > maxVal
        img = maxVal;
    elseif img < minVal
        img = minVal;
    end
    b = uint8(img);
    
end

function b = grayto8uint8(img)
b = uint8(double(img) * 1/257);
