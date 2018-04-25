function u = im2uint16(img, varargin)
%IM2UINT16 Convert gpuArray image to 16-bit unsigned integers.
%   IM2UINT16 takes a gpuArray image as input, and returns a gpuArray image
%   of underlying class uint16. If the input gpuArray image is of class
%   uint16, the output gpuArray is identical to it. If the input gpuArray
%   image is not uint16, IM2UINT16 returns the equivalent gpuArray image of
%   underlying class uint16, rescaling or offsetting the data as necessary.
%
%   I2 = IM2UINT16(I1) converts the intensity gpuArray image I1 to uint16,
%   rescaling the data if necessary.
%
%   RGB2 = IM2UINT16(RGB1) converts the truecolor gpuArray image RGB1 to
%   uint16, rescaling the data if necessary.
%
%   X2 = IM2UINT16(X1,'indexed') converts the indexed gpuArray image X1 to
%   uint16, offsetting the data if necessary.  If X1 is double, then the
%   maximum value of X1 must be 65536 or less.
%
%   I = IM2UINT16(BW) converts the binary image BW to a uint16 gpuArray
%   intensity image, changing one-valued elements to 65535.
%
%   Class Support
%   -------------
%   Intensity and truecolor gpuArray images can be uint8, uint16, double,
%   logical, single, or int16. Indexed images can be uint8, uint16, double
%   or logical. Binary input images must be logical. The output image is
%   uint16.
%
%   Example
%   -------
%       I1 = gpuArray(reshape(linspace(0,1,20),[5 4]))
%       I2 = im2uint16(I1)
%
%   See also GPUARRAY/IM2DOUBLE, GPUARRAY/IM2INT16, GPUARRAY/IM2SINGLE,
%            GPUARRAY/IM2UINT8, GPUARRAY/UINT16, GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.

%% inputs
narginchk(1,2);

classIn = classUnderlying(img);
hValidateAttributes(img,...
    {'double','logical','uint8','uint16','int16','single'}, ...
    {'nonsparse'},mfilename,'IMG',1);

if(~isreal(img))
    warning(message('images:im2uint16:ignoringImaginaryPartOfInput'));
    img = real(img);
end

if nargin == 2
    validatestring(varargin{1}, {'indexed'}, mfilename, 'type', 2);
end

%% process


if strcmp(classIn, 'uint16')
    u = img;
    
elseif islogical(img)
    u = uint16(img) * 65535;
    
elseif strcmp(classIn,'int16')
    if nargin == 1
        u = arrayfun(@int16touint16,img);
    else
        error(message('images:im2uint16:invalidIndexedImage'))
    end
    
else %double, single, or uint8
    if nargin==1
        % intensity image
        if strcmp(classIn, 'double')
            u = arrayfun(@grayto16double,img);
        elseif strcmp(classIn, 'single')
            u = arrayfun(@grayto16single,img);
        elseif strcmp(classIn, 'uint8')
            u = arrayfun(@grayto16uint8,img);
        end
        
    else
        if strcmp(classIn, 'uint8')
            u = uint16(img);
        else
            % img is double or single
            s.type = '()';
            s.subs = {':'};
            if any(max(subsref(img,s)) >= 65537)
                error(message('images:im2uint16:tooManyColors'))
            elseif any(min(subsref(img,s)) < 1)
                error(message('images:im2uint16:invalidIndex'))
            else
                u = uint16(img-1);
            end
        end
    end
end

function b = grayto16uint8(img)
%GRAYTO16 Scale and convert grayscale image to uint16.
%   B = GRAYTO16(A) converts the uint8 array A by scaling the
%   elements of A by 257 and then casting to uint8.

b = bitor(bitshift(uint16(img),8),uint16(img));

function b = grayto16double(img)
%GRAYTO16 Scale and convert grayscale image to uint16.
%   B = GRAYTO16(A) converts the double array A to uint16 by
%   scaling A by 65535 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 65535;
%   values less than 0.0 are converted to 0.

if isnan(img)
    b = uint16(0);
else
    % uint16() rounds DOUBLE and SINGLE values. No need to add 0.5 as in
    % grayto16 MEX code
    img = img * 65535;
    if img > 65535
        img = 65535;
    elseif img < 0
        img = 0;
    end
    b = uint16(img);
    
end

function b = grayto16single(img)
%GRAYTO16 Scale and convert grayscale image to uint16.
%   B = GRAYTO16(A) converts the double array A to uint16 by
%   scaling A by 65535 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 65535;
%   values less than 0.0 are converted to 0.

if isnan(img)
    b = uint16(0);
else
    % uint16() rounds DOUBLE and SINGLE values. No need to add 0.5 as in
    % grayto16 MEX code
    maxVal = single(65535);
    minVal = single(0);
    img = img * maxVal;
    if img > maxVal
        img = maxVal;
    elseif img < minVal
        img = minVal;
    end
    b = uint16(img);
    
end

function z = int16touint16(img)
%INT16TOUINT16 converts int16 to uint16
%   Z = INT16TOUINT16(I) converts int16 data (range = -32768 to 32767) to uint16
%   data (range = 0 to 65535).

z = uint16(int32(img) + 32768);
